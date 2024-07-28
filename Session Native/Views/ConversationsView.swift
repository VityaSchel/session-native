import SwiftUI
import SwiftData

struct ConversationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Conversation]

    var body: some View {
        Text("Select a conversation")
    }
}

struct ConversationsNav: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Conversation]
  @State var deleteAlert: Bool = false
  @State var deleteAlertLocalOnly: Bool = false
  
  var body: some View {
    List(items, id: \.id) { conversation in
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
            print("Muting conversation")
          } label: {
            Label("Mute", systemImage: "bell.slash.fill")
          }
          .tint(.indigo)
          Button {
            print("Move to archive")
            
          } label: {
            Label("Move to archive", systemImage: "archivebox.fill")
          }
          
          Button(role: .destructive) {
            print("Deleting conversation")
            deleteAlert = true
            deleteAlertLocalOnly = true
          } label: {
            Label("Delete", systemImage: "trash.fill")
          }
        }
        .alert("Delete this conversation?", isPresented: $deleteAlert) {
          Button("Delete everywhere", role: .destructive) {
            
          }
          Button("Delete locally", role: .destructive) {
            
          }
          Button("Cancel", role: .cancel) {
            deleteAlert = false
          }
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
    NavigationLink {
      
    } label: {
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
  }
}

struct ConversationsToolbar: ToolbarContent {
  @Environment(\.modelContext) private var modelContext
  
  var body: some ToolbarContent {
    ToolbarItem {
      Spacer()
    }
    ToolbarItem {
      Button(action: addItem) {
        Label("New conversation", systemImage: "square.and.pencil")
      }
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
        .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: 400)
      } detail: {
        ConversationsView()
      }
    }
    .modelContainer(inMemoryModelContainer)
    .environmentObject(UserManager(container: inMemoryModelContainer))
    .environmentObject(ViewManager(.conversations))
  }
}
