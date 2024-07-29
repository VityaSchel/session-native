import SwiftUI
import SwiftData

struct ConversationsView: View {
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject private var viewManager: ViewManager
  @Query private var items: [Conversation]

  var body: some View {
    switch(viewManager.navigationSelection) {
    case "new":
      NewConversationView()
    case nil:
      TipsView()
    default:
      ConversationView()
    }
  }
}

struct ConversationsNav: View {
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject var viewManager: ViewManager
  @Query private var items: [Conversation]
  @State var deleteAlertConversation: Conversation? = nil
  @State var deleteAlertVisible: Bool = false
  
  var body: some View {
    List(items, id: \.id, selection: $viewManager.navigationSelection) { conversation in
      ConversationPreviewItem(item: conversation)
        .swipeActions(edge: .leading) {
          Button {
            print("Read conversation")
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
          Button {
            print("Move to archive")
            
          } label: {
            Label("Move to archive", systemImage: "archivebox.fill")
          }
          
          Button(role: .destructive) {
            deleteAlertVisible = true
            deleteAlertConversation = conversation
          } label: {
            Label("Delete", systemImage: "trash.fill")
          }
        }
    }
    .alert("Delete this conversation?", isPresented: $deleteAlertVisible) {
      Button("Delete everywhere", role: .destructive) {
        
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
      
    })
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}

struct ConversationPreviewItem: View {
  var item: Conversation
  @EnvironmentObject var userManager: UserManager
  
  var body: some View {
    NavigationLink(
      value: item.id.uuidString,
      label: {
        Avatar(avatar: item.recipient.avatar)
        VStack(alignment: .leading) {
          HStack(alignment: .center, spacing: 4) {
            Text(item.recipient.displayName ?? getSessionIdPlaceholder(sessionId: item.recipient.sessionId))
              .fontWeight(.bold)
            if !item.notifications.enabled {
              Image(systemName: "speaker.slash.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 12)
                .padding(.top, 4)
                .opacity(0.45)
            }
          }
          if let lastMessage = item.lastMessage {
            if lastMessage.from.sessionId == userManager.activeUser?.sessionId {
              (Text("You: ")
                .foregroundStyle(.opacity(0.6))
              + Text(lastMessage.body)
                .foregroundColor(.primary)
               )
                .lineLimit(2)
            } else {
              Text(lastMessage.body)
                .foregroundColor(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            }
          } else {
            Text("Empty chat")
              .foregroundStyle(.opacity(0.6))
          }
        }
      }
    )
  }
}

struct ConversationsToolbar: ToolbarContent {
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject var viewManager: ViewManager
  
  var body: some ToolbarContent {
    ToolbarItem {
      Spacer()
    }
    ToolbarItem {
      Button(
        action: {
          viewManager.setActiveNavigationSelection("new")
        }
      ) {
        Label("New conversation", systemImage: "square.and.pencil")
      }
      .if(viewManager.navigationSelection == "new", { view in
        view
          .background(Color.accentColor)
          .cornerRadius(5)
      })
    }
  }
  
  @MainActor private func addItem() {
    let conversations = getConversationsPreviewMocks()
    modelContext.container.mainContext.insert(conversations[0])
    try! modelContext.container.mainContext.save()
  }
}

struct ConversationsView_Preview: PreviewProvider {
  static var previews: some View {
    let inMemoryModelContainer: ModelContainer = {
      do {
        let container = try ModelContainer(for: Schema(storageSchema), configurations: [.init(isStoredInMemoryOnly: true)])
        let convos = getConversationsPreviewMocks()
        container.mainContext.insert(convos[0])
        container.mainContext.insert(convos[1])
        container.mainContext.insert(convos[2])
        let users = getUsersPreviewMocks()
        container.mainContext.insert(users[0])
        try container.mainContext.save()
        UserDefaults.standard.set(users[0].id.uuidString, forKey: "activeUser")
        return container
      } catch {
        fatalError("Could not create ModelContainer: \(error)")
      }
    }()
    
    return Group {
      NavigationSplitView {
        VStack {
          ConversationsNav()
          AppViewsNavigation()
        }
        .toolbar {
          ConversationsToolbar()
        }
        .frame(minWidth: 200)
        .toolbar(removing: .sidebarToggle)
      } detail: {
        ConversationsView()
      }
    }
    .modelContainer(inMemoryModelContainer)
    .environmentObject(UserManager(container: inMemoryModelContainer))
    .environmentObject(ViewManager(.conversations))
  }
}
