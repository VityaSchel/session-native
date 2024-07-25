import SwiftUI
import SwiftData

enum AppView {
  case contacts
  case conversations
  case settings
  case auth
  case login
  case signup
}

struct ContentView: View {
  @EnvironmentObject var appViewManager: ViewManager
  @State private var searchText = ""
    
  var body: some View {
    switch appViewManager.appView {
    case .contacts, .conversations, .settings:
      NavigationSplitView {
        VStack {
          switch appViewManager.appView {
          case .contacts:
            ContactsNav()
          case .conversations:
            ConversationsNav()
          case .settings:
            SettingsNav()
          default:
            EmptyView()
          }
          AppViewsNavigation()
        }
        .toolbar {
          switch appViewManager.appView {
          case .contacts:
            ContactsToolbar()
          case .conversations:
            ConversationsToolbar()
          case .settings:
            SettingsToolbar()
          default:
            ToolbarItem{}
          }
        }
        .frame(minWidth: 200)
        .toolbar(removing: .sidebarToggle)
        .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: 400)
      } detail: {
      }
    case .auth, .login, .signup:
      NavigationStack {
        switch(appViewManager.appView) {
        case .auth:
          AuthView()
        case .login:
          LoginView()
        case .signup:
          SignupView()
        default:
          EmptyView()
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    let inMemoryModelContainer: ModelContainer = {
      do {
        return try ModelContainer(for: Schema(storageSchema), configurations: [.init(isStoredInMemoryOnly: true)])
      } catch {
        fatalError("Could not create ModelContainer: \(error)")
      }
    }()
                                  
    return ContentView()
      .modelContainer(inMemoryModelContainer)
      .environmentObject(UserManager(container: inMemoryModelContainer))
      .environmentObject(ViewManager())
  }
}
