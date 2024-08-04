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
    
    let userManager = UserManager(container: inMemoryModelContainer)
    
    return Group {
      NavigationSplitView {
        VStack {
          ConversationsNav(userManager: userManager)
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
    .environmentObject(userManager)
    .environmentObject(ViewManager(.conversations))
  }
}
