import Foundation
import SwiftUI

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
            NavigationLink(
              value: user.id.uuidString
            ) {
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
        NavigationLink(
          value: "add-session"
        ) {
          Image(systemName: "person.badge.plus")
            .frame(width: 24, height: 24)
            .background(Color.gray.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
          Text("Add Session")
        }
        Section {
          NavigationLink(
            value: "general"
          ) {
            Image(systemName: "gear")
              .frame(width: 24, height: 24)
              .background(Color.gray.gradient)
              .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text("General")
          }
          NavigationLink(
            value: "notifications"
          ) {
            Image(systemName: "app.badge")
              .frame(width: 24, height: 24)
              .background(Color.red.gradient)
              .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text("Notifications & Sound")
          }
          NavigationLink(
            value: "privacy"
          ) {
            Image(systemName: "lock")
              .frame(width: 24, height: 24)
              .background(Color.blue.gradient)
              .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text("Privacy")
          }
          NavigationLink(
            value: "appearance"
          ) {
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
          NavigationLink(
            value: "help"
          ) {
            Image(systemName: "questionmark.circle.fill")
              .resizable()
              .scaledToFit()
              .padding(.all, 5)
              .frame(width: 24, height: 24)
              .background(Color.cyan.gradient.secondary)
              .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text("Help")
          }
          NavigationLink(
            value: "bug-report"
          ) {
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
    .onChange(of: viewManager.navigationSelection) {
      switch(viewManager.navigationSelection) {
      case "profile", "general", "notifications", "privacy", "appearance", "help":
        break
      case "add-session":
        viewManager.setActiveView(.auth)
        break
      case "bug-report":
        let url = URL(string: "https://github.com/VityaSchel/session-native/issues")!
        NSWorkspace.shared.open(url)
        break
      default:
        if let user = userManager.users.first(where: { $0.id.uuidString == viewManager.navigationSelection }) {
          userManager.setActiveUser(user)
        }
        break
      }
    }
  }
}
