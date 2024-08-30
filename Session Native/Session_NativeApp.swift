import SwiftUI
import SwiftData

@main
struct Session_NativeApp: App {
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
  
  init() {
    let userManager = UserManager(container: sharedModelContainer)
    _userManager = StateObject(wrappedValue: userManager)
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(userManager)
        .environmentObject(viewManager)
        .environmentObject(connectionStatusManager)
    }
    .modelContainer(sharedModelContainer)
  }
}
