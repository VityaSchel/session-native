import SwiftUI
import SwiftData

enum AppView {
  case contacts
  case conversations
  case settings
}

struct ContentView: View {
  @State private var visibleView: AppView = .conversations
  @State private var searchText = ""
  
  var body: some View {
      switch visibleView {
      case .contacts, .conversations, .settings:
        NavigationSplitView {
          VStack {
            switch visibleView {
            case .contacts:
              ContactsNav()
            case .conversations:
              ConversationsNav()
            case .settings:
              SettingsNav()
            }
            AppViewsNavigation(appView: $visibleView)
          }
          .toolbar {
            switch visibleView {
            case .contacts:
              ContactsToolbar()
            case .conversations:
              ConversationsToolbar()
            case .settings:
              SettingsToolbar()
            }
          }
          .toolbar(removing: .sidebarToggle)
          .searchable(text: $searchText, placement: .sidebar)
          .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: 400)
        } detail: {
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .modelContainer(for: Item.self, inMemory: true)
  }
}
