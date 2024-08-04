import Foundation
import SwiftUI
import SwiftData

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
              Spacer()
            }
            Spacer()
            Spacer()
            Image(systemName: "archivebox.fill")
            Text("Archive")
              .fontWeight(.medium)
            Spacer()
            Spacer()
            if archive {
              Spacer()
            } else {
              Image(systemName: "arrow.right")
                .padding(.trailing, 6)
            }
          }
          .animation(.none)
          .foregroundStyle(Color.gray)
          .padding(.vertical, 6)
          .frame(width: .infinity)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets(top: 0, leading: -16, bottom: 0, trailing: -16))
        .contentShape(Rectangle())
        .listRowBackground(Color.gray.opacity(0.1))
      }
      ForEach(items
        .filter { conversation in
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
        },
        id: \.id
      ) { conversation in
          ConversationPreviewItem(
            conversation: conversation,
            onDelete: {
              deleteAlertVisible = true
              deleteAlertConversation = conversation
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
  }
}

struct ConversationPreviewItem: View {
  var conversation: Conversation
  @EnvironmentObject var userManager: UserManager
  @EnvironmentObject var viewManager: ViewManager
  @State var selected: Bool = false
  var onDelete: () -> Void
  
  var body: some View {
    Button {
      viewManager.setActiveNavigationSelection(conversation.id.uuidString)
    } label: {
      HStack {
        Avatar(avatar: conversation.recipient.avatar)
        VStack(alignment: .leading) {
          HStack(alignment: .center, spacing: 4) {
            Text(conversation.contact?.name ?? conversation.recipient.displayName ?? getSessionIdPlaceholder(sessionId: conversation.recipient.sessionId))
              .fontWeight(.bold)
              .foregroundStyle(selected ? Color.black.opacity(0.8) : Color.white)
            if !conversation.notifications.enabled {
              Image(systemName: "speaker.slash.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 12)
                .padding(.top, 4)
                .foregroundStyle(selected ? Color.black : Color.white)
                .opacity(0.45)
            }
          }
          if let lastMessage = conversation.lastMessage {
            if lastMessage.from == nil {
              if selected {
                (Text("You: ")
                  .foregroundStyle(Color.black.opacity(0.3))
                 + Text(lastMessage.body)
                  .foregroundStyle(Color.black.opacity(0.6))
                )
                .lineLimit(2)
              } else {
                (Text("You: ")
                  .foregroundStyle(.opacity(0.4))
                 + Text(lastMessage.body)
                  .foregroundStyle(.opacity(0.6))
                )
                .lineLimit(2)
              }
            } else {
              Text(lastMessage.body)
                .foregroundStyle(selected ? Color.black.opacity(0.6) : Color.white.opacity(0.6))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            }
          } else {
            Text("Empty chat")
              .foregroundStyle(selected ? Color.black.opacity(0.3) : Color.white.opacity(0.4))
          }
        }
        Spacer()
        VStack(alignment: .trailing) {
          Text(shortConversationUpdatedAt(conversation.updatedAt))
            .foregroundStyle(selected ? Color.black.opacity(0.3) : Color.white.opacity(0.4))
          Spacer()
          HStack {
            if conversation.unreadMessages > 0 {
              Group {
                Text(
                  conversation.unreadMessages > 99
                    ? "99+"
                    : String(conversation.unreadMessages)
                )
                  .font(.system(size: 10))
              }
              .frame(width: conversation.unreadMessages > 99 ? 24 : 20, height: 20)
              .background(Color.linkButton)
              .cornerRadius(.infinity)
            }
            if conversation.pinned {
              Image(systemName: "pin.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .rotationEffect(.degrees(45))
                .foregroundStyle(selected ? Color.black.opacity(0.3) : Color.white.opacity(0.4))
            }
          }
        }
      }
      .contentShape(Rectangle())
      .padding(.vertical, 6)
    }
    .buttonStyle(.plain)
    .onChange(of: viewManager.navigationSelection) {
      selected = viewManager.navigationSelection == conversation.id.uuidString
    }
    .if(selected) { view in
      view.listRowBackground(Color.accentColor)
    }
    .swipeActions(edge: .leading) {
      Button {
        conversation.messages.forEach({ message in
          message.read = true
        })
      } label: {
        Label("", systemImage: "message.badge.filled.fill")
      }
      .tint(.blue)
    }
    .swipeActions(edge: .trailing) {
      Button {
        conversation.notifications.enabled = !conversation.notifications.enabled
      } label: {
        if conversation.notifications.enabled {
          Label("", systemImage: "bell.slash.fill")
        } else {
          Label("", systemImage: "bell.fill")
        }
      }
      .tint(.indigo)
      .accessibility(label: Text(conversation.notifications.enabled ? "Mute conversation" : "Unmute conversation"))
      Button(role: .destructive) {
        onDelete()
      } label: {
        Label("", systemImage: "trash.fill")
      }
      .accessibility(label: Text("Delete conversation"))
      Button {
        withAnimation {
          conversation.archived.toggle()
        }
      } label: {
        Label("", systemImage: conversation.archived ? "square.and.arrow.up.fill" : "archivebox.fill")
      }
      .accessibility(label: Text(conversation.archived ? "Unarchive conversation" : "Archive conversation"))
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
          //          try? modelContext.save()
        }
      } else {
        Button("􀋙 Unmute") {
          conversation.notifications.enabled = true
          //          try? modelContext.save()
        }
      }
      Button("􀌤 Mark as read") {
        // TODO: unread counter
      }
      Divider()
      if(conversation.archived) {
        Button("􀈂 Unarchive") {
          conversation.archived = false
        }
      } else {
        Button("􀈭 Archive") {
          conversation.archived = true
        }
      }
      Divider()
      Button("􀁠 Clear history") {
        // TODO: clear history of messages without deleting conversation (with confirmation dialog)
      }
      Button {
        onDelete()
      } label: {
        Label("􀈑 Delete conversation", systemImage: "trash")
          .foregroundStyle(Color.red)
      }
    }))
  }
  
  private func shortConversationUpdatedAt(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    
    if calendar.isDateInYesterday(date) || calendar.isDateInToday(date) {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm"
      return formatter.string(from: date)
    }
    
    if let daysAgo = calendar.date(byAdding: .day, value: -6, to: now),
       date >= daysAgo {
      let formatter = DateFormatter()
      formatter.dateFormat = "EE"
      let dayString = formatter.string(from: date)
      return String(dayString.prefix(2))
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "d.MM.yy"
    return formatter.string(from: date)
  }
}

#Preview {
  ConversationsView_Preview.previews
}
