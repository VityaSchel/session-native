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
  @StateObject private var keyMonitor = GlobalKeyMonitor()
  @EnvironmentObject var appViewManager: ViewManager
  @EnvironmentObject var userManager: UserManager
  @EnvironmentObject var connectionStatusManager: ConnectionStatusManager
  @Environment(\.modelContext) private var modelContext
  @State private var searchText = ""
  @State private var connected = false
  @AppStorage("theme") private var theme: String = "auto"
  @State private var eventHandler: EventHandler? = nil
    
  var body: some View {
    Group {
      if connected {
        switch appViewManager.appView {
        case .contacts, .conversations, .settings:
          NavigationSplitView {
            VStack {
              switch appViewManager.appView {
              case .contacts:
                ContactsNav(userManager: userManager)
              case .conversations:
                ConversationsNav(userManager: userManager)
              case .settings:
                SettingsNav()
              default:
                EmptyView()
              }
              ConnectionStatusView()
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
            switch appViewManager.appView {
            case .contacts:
              ContactsView()
            case .conversations:
              ConversationsView()
            case .settings:
              SettingsView()
            default:
              EmptyView()
            }
          }
          .frame(minWidth: 600, minHeight: 400)
        case .auth, .login, .signup:
          if(appViewManager.appView == .login || appViewManager.appView == .signup || (appViewManager.appView == .auth && userManager.activeUser != nil)) {
            HStack {
              Button(action: {
                if(appViewManager.appView == .login || appViewManager.appView == .signup) {
                  appViewManager.setActiveView(.auth)
                } else if(appViewManager.appView == .auth) {
                  appViewManager.setActiveView(.settings)
                }
              }) {
                Image(systemName: "chevron.backward")
              }
              .buttonStyle(ToolbarButtonStyle())
              Spacer()
            }
            .padding(.top, 7)
            .padding(.horizontal, 12)
          }
          Spacer()
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
          Spacer()
        }
      } else {
        VStack(spacing: 12) {
          Text("Unexpected error occured")
            .font(.title)
          Text("Session Native can't connect to the Bun backend via unix socket. Please create an issue on GitHub specifying as much details about your OS, environment and actions that led to this error as possible.")
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 64)
        .frame(minWidth: 600, minHeight: 400)
      }
    }
    .onAppear() {
      request([
        "type": "ping"
      ], { response in
        if(response["ok"]?.boolValue == true) {
          connected = true
          if userManager.activeUser != nil {
            DispatchQueue.main.async {
              appViewManager.setActiveView(.conversations)
            }
          }
        }
      })
      requestNotificationAuthorization()
    }
    .preferredColorScheme(
      theme == "dark"
      ? .dark
      : theme == "light"
      ? .light
      : .none
    )
    .onAppear {
      self.eventHandler = EventHandler(
        modelContext: modelContext,
        userManager: userManager,
        viewManager: appViewManager,
        connectionStatusManager: connectionStatusManager
      )
      self.eventHandler?.subscribeToEvents()
    }
    .environmentObject(keyMonitor)
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
      .environmentObject(UserManager(container: inMemoryModelContainer, preview: true))
      .environmentObject(ViewManager())
      .environmentObject(ConnectionStatusManager())
  }
}
