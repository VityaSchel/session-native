import SwiftUI
import SwiftData

@main
struct Session_NativeApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var sharedModelContainer: ModelContainer = {
    let schema = Schema(storageSchema)
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  @StateObject private var userManager: UserManager
  @StateObject private var viewManager = ViewManager()
  @StateObject private var connectionStatusManager = ConnectionStatusManager()
  @State private var isSidecarRunning = false
  @StateObject private var sidecarManager = SidecarManager.shared

  init() {
    let userManager = UserManager(container: sharedModelContainer)
    _userManager = StateObject(wrappedValue: userManager)
  }

  var body: some Scene {
    WindowGroup {
      if sidecarManager.isSidecarRunning {
        ContentView()
          .environmentObject(userManager)
          .environmentObject(viewManager)
          .environmentObject(connectionStatusManager)
      } else {
        if let appIcon = NSImage(named: NSImage.Name("AppIcon")) {
          Image(nsImage: appIcon)
            .resizable()
            .scaledToFit()
            .frame(width: 256, height: 256)
        }
      }
    }
    .modelContainer(sharedModelContainer)
  }
}
