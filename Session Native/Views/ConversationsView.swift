import SwiftUI
import SwiftData
import Combine

struct ConversationsView: View {
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject private var viewManager: ViewManager
  @EnvironmentObject private var userManager: UserManager

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

class ConversationsViewModel: ObservableObject {
  @Published var items: [Conversation] = []
  @Published var isLoading = false
  private var cancellables = Set<AnyCancellable>()
  
  private var dbContext: ModelContext
  
  init(context: ModelContext, activeUser: User) {
    self.dbContext = context
    fetchItems(activeUser: activeUser)
  }
  
  func fetchItems(activeUser: User) {
    guard !isLoading else { return }
    isLoading = true
    
    do {
      let activeUserId = activeUser.persistentModelID
      var fetchDescriptor = FetchDescriptor(predicate: #Predicate<Conversation> { conversation in
        conversation.user.persistentModelID == activeUserId
      })
      fetchDescriptor.sortBy = [SortDescriptor(\Conversation.updatedAt, order: .reverse)]
      
      let fetchedItems = try dbContext.fetch(fetchDescriptor).reversed()
      
      DispatchQueue.main.async {
        self.items.insert(contentsOf: fetchedItems, at: 0)
        self.isLoading = false
      }
    } catch {
      print("Failed to fetch items: \(error)")
      self.isLoading = false
    }
  }
}

struct ConversationsNav: View {
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var viewManager: ViewManager
  @EnvironmentObject var userManager: UserManager
  
  var body: some View {
    ConversationsList(context: modelContext, modelContext: modelContext, userManager: userManager, viewManager: viewManager)
  }
  
  struct ConversationsList: View {
    @Environment(\.modelContext) var modelContext
    var userManager: UserManager
    @State var viewManager: ViewManager
    @State private var deleteAlertConversation: Conversation? = nil
    @State private var deleteAlertVisible: Bool = false
    @StateObject private var viewModel: ConversationsViewModel
    @State private var searchText = ""
    
    init(context: ModelContext, modelContext: ModelContext, userManager: UserManager, viewManager: ViewManager) {
      self.viewManager = viewManager
      self.userManager = userManager
      self.deleteAlertConversation = nil
      self.deleteAlertVisible = false
      _viewModel = StateObject(
        wrappedValue: ConversationsViewModel(
          context: modelContext,
          activeUser: userManager.activeUser!
        )
      )
    }
    
    var body: some View {
      List(viewModel.items, id: \.id, selection: $viewManager.navigationSelection) { conversation in
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
            if(conversation.archived) {
              Button {
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
              
            }
            Button {
              
            } label: {
              Label("􀈑 Delete conversation", systemImage: "trash")
                .foregroundStyle(Color.red)
            }
          }))
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
          modelContext.delete(viewModel.items[index])
        }
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
        HStack {
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
              if lastMessage.from == nil {
                (Text("You: ")
                  .foregroundStyle(.opacity(0.4))
                 + Text(lastMessage.body)
                  .foregroundStyle(.opacity(0.6))
                )
                .lineLimit(2)
              } else {
                Text(lastMessage.body)
                  .foregroundStyle(.opacity(0.6))
                  .lineLimit(2)
                  .fixedSize(horizontal: false, vertical: true)
              }
            } else {
              Text("Empty chat")
                .foregroundStyle(.opacity(0.4))
            }
          }
          Spacer()
          VStack(alignment: .trailing) {
            Text(shortConversationUpdatedAt(item.updatedAt))
              .foregroundStyle(.opacity(0.4))
            Spacer()
            if item.pinned {
              Image(systemName: "pin.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .rotationEffect(.degrees(45))
                .foregroundStyle(.opacity(0.4))
            }
          }
        }
      }
    )
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
}

struct ConversationsView_Preview: PreviewProvider {
  static var previews: some View {
    let inMemoryModelContainer: ModelContainer = {
      do {
        let container = try ModelContainer(for: Schema(storageSchema), configurations: [.init(isStoredInMemoryOnly: true)])
        let users = getUsersPreviewMocks()
        container.mainContext.insert(users[0])
        let convos = getConversationsPreviewMocks(user: users[0])
        container.mainContext.insert(convos[0])
        container.mainContext.insert(convos[1])
        container.mainContext.insert(convos[2])
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
