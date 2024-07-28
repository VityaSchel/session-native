import SwiftUI
import SwiftData

struct SettingsView: View {
    var body: some View {
        Text("Select a setting")
    }
}

struct SettingsNav: View {
  @EnvironmentObject var userManager: UserManager
  @EnvironmentObject var viewManager: ViewManager
  
  var body: some View {
    List(selection: $viewManager.navigationSelection) {
      Section {
        if let activeUser = userManager.activeUser {
          NavigationLink(
            value: "profile"
          ) {
            Avatar(avatar: activeUser.avatar, width: 64, height: 64)
            VStack(alignment: .leading, spacing: 6) {
              Text(activeUser.displayName ?? getSessionIdPlaceholder(sessionId: activeUser.sessionId))
              .font(.system(size: 18, weight: .semibold))
              Text(activeUser.sessionId)
                .font(.system(size: 10))
                .lineLimit(2)
                .truncationMode(.middle)
                .opacity(0.75)
            }
            .padding(.leading, 8)
          }
          .padding(.all, 6)
        }
        ForEach(userManager.users) { user in
          if(user.id != userManager.activeUser?.id) {
            NavigationLink {
              Text(user.sessionId)
            } label: {
              Avatar(avatar: user.avatar, width: 24, height: 24)
              VStack(alignment: .leading) {
                Text(user.displayName ?? getSessionIdPlaceholder(sessionId: user.sessionId))
                  .font(.system(size: 12))
                Text(user.sessionId)
                  .font(.system(size: 10))
                  .foregroundStyle(Color.gray.opacity(0.9))
                  .truncationMode(.middle)
              }
            }
          }
        }
        NavigationLink {
          Text("great")
        } label: {
          Image(systemName: "person.badge.plus")
            .frame(width: 24, height: 24)
            .background(Color.gray.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
          Text("Add account")
        }
        Section {
          NavigationLink {
            Text("great")
          } label: {
            Image(systemName: "gear")
              .frame(width: 24, height: 24)
              .background(Color.gray.gradient)
              .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text("General")
          }
          NavigationLink {
            Text("great")
          } label: {
            Image(systemName: "app.badge")
              .frame(width: 24, height: 24)
              .background(Color.red.gradient)
              .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text("Notifications & sound")
          }
          NavigationLink {
            Text("great")
          } label: {
            Image(systemName: "lock")
              .frame(width: 24, height: 24)
              .background(Color.blue.gradient)
              .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text("Privacy")
          }
          NavigationLink {
            Text("great")
          } label: {
            Image(systemName: "bubble.left.and.bubble.right")
              .resizable()
              .scaledToFit()
              .padding(.all, 4)
              .frame(width: 24, height: 24)
              .background(Color.green.gradient)
              .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text("Chats & appearance")
          }
        }
        Section {
          NavigationLink {
            Text("great")
          } label: {
            Image(systemName: "questionmark.circle.fill")
              .resizable()
              .scaledToFit()
              .padding(.all, 5)
              .frame(width: 24, height: 24)
              .background(Color.cyan.gradient.secondary)
              .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text("Help")
          }
          NavigationLink {
            Text("https://github.com/VityaSchel/session-native")
          } label: {
            Image(systemName: "ladybug.fill")
              .frame(width: 24, height: 24)
              .background(Color.purple.gradient.secondary)
              .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text("Report a bug")
          }
        }
        Section {
          VStack(alignment: .leading) {
            Text("Session Native by hloth.dev")
              .foregroundStyle(Color.white.opacity(0.5))
            Text("v1.0.0 Stable standalone")
              .foregroundStyle(Color.white.opacity(0.5))
          }
        }
      }
    }
  }
}

struct SettingsToolbar: ToolbarContent {
  @EnvironmentObject var viewManager: ViewManager
  
  var body: some ToolbarContent {
    ToolbarItem {
      Spacer()
    }
    ToolbarItem {
      Button(action: {
        viewManager.setActiveNavigationSelection("profile")
      }) {
        Text("Edit")
      }
      .buttonStyle(.link)
    }
  }
}

struct SettingsView_Preview: PreviewProvider {
  static var previews: some View {
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
    .environmentObject(ViewManager(.settings))
  }
}
