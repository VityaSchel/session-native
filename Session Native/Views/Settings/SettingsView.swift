import SwiftUI
import SwiftData

struct SettingsView: View {
  @EnvironmentObject var viewManager: ViewManager
  
  var body: some View {
    ScrollView {
      switch(viewManager.navigationSelection) {
      case "profile":
        ProfileSettingsView()
      case "connection":
        ConnectionSettingsView()
      case "notifications":
        NotificationsSettingsView()
      case "privacy":
        PrivacySettingsView()
      case "appearance":
        AppearanceSettingsView()
      case "help":
        HelpView()
      default:
        EmptyView()
      }
      Spacer()
    }
    .onAppear {
      if(viewManager.navigationSelection == nil) {
        viewManager.setActiveNavigationSelection("profile")
      }
    }
  }
}

struct SettingsView_Preview: PreviewProvider {
  static var previews: some View {
    previewWithTab()
  }
  
  static func previewWithTab(_ tab: String? = nil) -> some View {
    let inMemoryModelContainer: ModelContainer = {
      do {
        let container = try ModelContainer(for: Schema(storageSchema), configurations: [.init(isStoredInMemoryOnly: true)])
        let users = getUsersPreviewMocks()
        container.mainContext.insert(users[0])
        container.mainContext.insert(users[1])
        container.mainContext.insert(users[2])
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
          SettingsNav()
          AppViewsNavigation()
        }
        .toolbar {
          SettingsToolbar()
        }
        .frame(minWidth: 200)
        .toolbar(removing: .sidebarToggle)
        .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: 400)
      } detail: {
        SettingsView()
      }
    }
    .modelContainer(inMemoryModelContainer)
    .environmentObject(UserManager(container: inMemoryModelContainer))
    .environmentObject(ViewManager(.settings, tab))
  }
}
