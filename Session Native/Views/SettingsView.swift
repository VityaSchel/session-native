import SwiftUI
import SwiftData

struct SettingsView: View {

    var body: some View {
        Text("Select a conversation")
    }
}

struct SettingsNav: View {
  @EnvironmentObject var userManager: UserManager
  
  var body: some View {
    List {
      Section {
        NavigationLink {
          
        } label: {
          if let activeUser = userManager.activeUser {
            Avatar(avatar: activeUser.avatar)
          }
        }
      }
    }
  }
}

struct SettingsToolbar: ToolbarContent {
  var body: some ToolbarContent {
    ToolbarItem {
      Spacer()
    }
    ToolbarItem {
      Button(action: addItem) {
        Text("Edit")
      }
      .buttonStyle(.link)
    }
  }
  
  private func addItem() {
    
  }
}

#Preview {
    SettingsView()
      .modelContainer(for: User.self, inMemory: true)
}
