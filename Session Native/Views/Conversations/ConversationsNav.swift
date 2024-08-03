import Foundation
import SwiftUI
import SwiftData

struct ConversationsNav: View {
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var userManager: UserManager
  @EnvironmentObject var viewManager: ViewManager
  @State private var deleteAlertConversation: Conversation? = nil
  @State private var deleteAlertVisible: Bool = false
  @State private var searchText = ""
  @Query private var items: [Conversation] = []
  @Binding private var selected: String?
  
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
    List(items
      .filter { conversation in
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
    ) { conversation in
      ConversationPreviewItem(item: conversation)
        .swipeActions(edge: .leading) {
          Button {
            print("Read conversation") // TODO: set unread to 0
          } label: {
            Label("Read", systemImage: "message.badge.filled.fill")
          }
          .tint(.blue)
        }
        .swipeActions(edge: .trailing) {
          Button {
            conversation.notifications.enabled = !conversation.notifications.enabled
          } label: {
            if conversation.notifications.enabled {
              Label("Mute", systemImage: "bell.slash.fill")
            } else {
              Label("Unmute", systemImage: "bell.fill")
            }
          }
          .tint(.indigo)
          if(conversation.archived) {
            Button {
              // TODO: conversations archive
              conversation.archived = false
            } label: {
              Label("Move from archive", systemImage: "square.and.arrow.up.fill")
            }
          } else {
            Button {
              conversation.archived = true
            } label: {
              Label("Move to archive", systemImage: "archivebox.fill")
            }
          }
          Button(role: .destructive) {
            deleteAlertVisible = true
            deleteAlertConversation = conversation
          } label: {
            Label("Delete", systemImage: "trash.fill")
          }
        }
        .contextMenu(ContextMenu(menuItems: {
          if(conversation.pinned) {
            Button("􀎨 Unpin") {
              conversation.pinned = false
            }
          } else {
            Button("􀎦 Pin") {
              conversation.pinned = true
            }
          }
          if(conversation.notifications.enabled) {
            Button("􀋝 Mute") {
              // TODO: notifications
              conversation.notifications.enabled = false
              try? modelContext.save()
            }
          } else {
            Button("􀋙 Unmute") {
              conversation.notifications.enabled = true
              try? modelContext.save()
            }
          }
          Button("􀌤 Mark as read") {
            // TODO: unread counter
          }
          Divider()
          if(conversation.archived) {
            Button("􀈭 Archive") {
              conversation.archived = true
            }
          } else {
            Button("􀈂 Unarchive") {
              conversation.archived = false
            }
          }
          Divider()
          Button("􀁠 Clear history") {
            // TODO: clear history of messages without deleting conversation (with confirmation dialog)
          }
          Button {
            deleteAlertVisible = true
            deleteAlertConversation = conversation
          } label: {
            Label("􀈑 Delete conversation", systemImage: "trash")
              .foregroundStyle(Color.red)
          }
        }))
    }
    .alert("Delete this conversation?", isPresented: $deleteAlertVisible) {
      Button("Delete everywhere", role: .destructive) {
        // TODO: delete messages request to backend
      }
      Button("Delete locally", role: .destructive) {
        if let conversation = deleteAlertConversation {
          modelContext.delete(conversation)
        }
      }
      Button("Cancel", role: .cancel) {
        deleteAlertVisible = false
      }
    }
    .onDeleteCommand(perform: {
      // TODO: find conversation by selection and delete it on esc press
    })
    .listStyle(.sidebar)
    .background(.clear)
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}
