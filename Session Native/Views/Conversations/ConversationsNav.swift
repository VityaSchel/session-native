import Foundation
import SwiftUI
import SwiftData
import MessagePack

struct ConversationsNav: View {
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var userManager: UserManager
  @EnvironmentObject var viewManager: ViewManager
  @State private var searchText = ""
  @Query private var items: [Conversation] = []
  @Binding private var selected: String?
  @State private var overscrollOffset: CGFloat = 0
  @State private var archive: Bool = false
  @State private var deleteAlertVisible: Bool = false
  @State private var deleteAlertConversation: Conversation?
  @State private var deleteLastConversationAlertVisible: Bool = false
  @State private var clearConversationAlertVisible: Bool = false
  @State private var clearConversationAlert: Conversation?
  @State private var conversationsItems: [Conversation] = []
  
  init(userManager: UserManager) {
    let activeUserId = userManager.activeUser!.persistentModelID
    let predicate = #Predicate<Conversation> {
      $0.user.persistentModelID == activeUserId
    }
    _items = Query(
      filter: predicate,
      sort: [SortDescriptor(\Conversation.updatedAt, order: .reverse)]
    )
    _selected = .constant("")
  }
  
  var body: some View {
    if viewManager.searchVisible {
      SearchField(searchText: $searchText)
        .padding(.horizontal, 12)
      Divider()
    }
    List {
      if items.contains(where: { $0.archived }) || archive {
        Button() {
          withAnimation {
            archive.toggle()
          }
        } label: {
          HStack {
            if archive {
              Image(systemName: "arrow.left")
                .padding(.leading, 6)
            } else {
              Rectangle()
                .opacity(0)
                .frame(width: 15)
                .padding(.leading, 6)
            }
            Spacer()
            Image(systemName: "archivebox.fill")
            Text("Archive")
              .fontWeight(.medium)
            Spacer()
            if archive {
              Rectangle()
                .opacity(0)
                .frame(width: 15)
                .padding(.trailing, 6)
            } else {
              Image(systemName: "arrow.right")
                .padding(.trailing, 6)
            }
          }
          .animation(.none)
          .foregroundStyle(Color.gray)
          .padding(.vertical, 6)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets(top: 0, leading: -16, bottom: 0, trailing: -16))
        .contentShape(Rectangle())
        .listRowBackground(Color.gray.opacity(0.1))
      }
      ForEach(conversationsItems) { conversation in
        ConversationPreviewItem(
          conversation: conversation,
          onClear: {
            clearConversationAlertVisible = true
            clearConversationAlert = conversation
          },
          onDelete: {
            if let index = conversationsItems.lastIndex(of: conversation) {
              if index == conversationsItems.count - 1 {
                deleteLastConversationAlertVisible = true
              } else {
                deleteAlertVisible = true
                deleteAlertConversation = conversation
              }
            }
          }
        )
      }
//      .onDeleteCommand(perform: {
//        // TODO: find conversation by selection and delete it on esc press
//      })
      .listStyle(.sidebar)
      .background(.clear)
    }
    .onChange(of: viewManager.searchVisible) { prev, cur in
      if(prev == true && cur == false) {
        searchText = ""
      }
    }
    .onChange(of: viewManager.navigationSelection, {
      if let conversationId = viewManager.navigationSelection {
        if let conversationUuid = UUID(uuidString: conversationId) {
          if let conversation = try? modelContext.fetch(
            FetchDescriptor(predicate: #Predicate<Conversation> { conversation in
              conversation.id == conversationUuid
            })
          ).first {
            archive = conversation.archived
          }
        }
      }
    })
    .onChange(of: items) {
      conversationsItems = getConversationsItems()
    }
    .onAppear {
      conversationsItems = getConversationsItems()
    }
    .alert("Clear this conversation?", isPresented: $clearConversationAlertVisible) {
      Button("Clear everywhere", role: .destructive) {
        if let conversation = clearConversationAlert {
          let messages = conversation.messages!.map({ message in
            MessagePackValue.map([
              "timestamp": MessagePackValue.int(message.timestamp!),
              "hash": MessagePackValue.string(message.messageHash!)
            ])
          })
          let deleteMessageRequest: [MessagePackValue: MessagePackValue] = [
            "type": "delete_messages",
            "conversation": MessagePackValue.string(conversation.recipient.sessionId),
            "messages": MessagePackValue.array(messages)
          ]
          request(.map(deleteMessageRequest), { response in
            if(response["ok"]?.boolValue == true) {
              DispatchQueue.main.async {
                deleteAlertVisible = false
                deleteAlertConversation = nil
                deleteMessagesFromDb(conversation)
              }
            }
          })
        }
      }
      Button("Clear locally", role: .destructive) {
        if let conversation = clearConversationAlert {
          deleteMessagesFromDb(conversation)
        }
      }
      Button("Cancel", role: .cancel) {
        clearConversationAlertVisible = false
      }
    }
    .alert(isPresented: $deleteLastConversationAlertVisible) {
      Alert(
        title: Text("Can't delete this conversation"),
        message: Text("Due to SwiftData bug, you can't delete last conversation in conversations list. Issue on GitHub: https://github.com/VityaSchel/session-native/issues/1."),
        dismissButton: .cancel()
      )
    }
    .alert("Delete this conversation?", isPresented: $deleteAlertVisible) {
      Button("Delete everywhere", role: .destructive) {
        if let conversation = deleteAlertConversation {
          let messages = conversation.messages!.map({ message in
            MessagePackValue.map([
              "timestamp": MessagePackValue.int(message.timestamp!),
              "hash": MessagePackValue.string(message.messageHash!)
            ])
          })
          let deleteMessageRequest: [MessagePackValue: MessagePackValue] = [
            "type": "delete_messages",
            "conversation": MessagePackValue.string(conversation.recipient.sessionId),
            "messages": MessagePackValue.array(messages)
          ]
          request(MessagePackValue.map(deleteMessageRequest), { response in
            if(response["ok"]?.boolValue == true) {
              DispatchQueue.main.async {
                deleteAlertVisible = false
                deleteAlertConversation = nil
                
                if(viewManager.navigationSelection == conversation.id.uuidString) {
                  viewManager.setActiveNavigationSelection(nil)
                }
                deleteMessagesFromDb(conversation)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                  deleteConversationFromDb(conversation)
                }
              }
            }
          })
        }
      }
      Button("Delete locally", role: .destructive) {
        if let conversation = deleteAlertConversation {
          DispatchQueue.main.async {
            if(viewManager.navigationSelection == conversation.id.uuidString) {
              viewManager.setActiveNavigationSelection(nil)
            }
            deleteMessagesFromDb(conversation)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              deleteConversationFromDb(conversation)
            }
          }
        }
      }
      Button("Cancel", role: .cancel) {
        deleteAlertVisible = false
      }
    }
  }
  
  private func getConversationsItems() -> [Conversation] {
    return items.filter { conversation in
      if(conversation.archived != archive) {
        return false
      }
      guard !searchText.isEmpty else {
        return true
      }
      let query = searchText.lowercased()
      if let name = conversation.contact?.name {
        return name.lowercased().contains(query)
      } else if let displayName = conversation.recipient.displayName {
        return displayName.lowercased().contains(query)
      } else {
        return conversation.recipient.sessionId.contains(query)
      }
    }
    .sorted { (lhs, rhs) -> Bool in
      if lhs.pinned == rhs.pinned {
        return false
      }
      return lhs.pinned && !rhs.pinned
    }
  }
  
  private func deleteMessagesFromDb(_ conversation: Conversation) {
    let conversationId = conversation.persistentModelID
    do {
      let messages = try modelContext.fetch(FetchDescriptor<Message>(predicate: #Predicate { message in
        if let conversation = message.conversation {
          return conversation.persistentModelID == conversationId
        } else {
          return false
        }
      }))
      messages.forEach({ msg in
        modelContext.delete(msg)
      })
      try modelContext.save()
      
      if let selectedConversationSessionId = self.viewManager.navigationSelection {
        if(selectedConversationSessionId == conversation.recipient.sessionId) {
          MessageViewModelNotifier.shared.messageDeleted.send(conversation)
        }
      }
    } catch {
      print("Failed to delete messages: \(error.localizedDescription)")
    }
  }
  
  private func deleteConversationFromDb(_ conversation: Conversation) {
    do {
      if let contact = conversation.contact {
        contact.conversation = nil
      }
      modelContext.delete(conversation)
      try modelContext.save()
    } catch {
      print("Failed to delete conversation: \(error.localizedDescription)")
    }
  }
}

#Preview {
  ConversationsView_Preview.previews
}
