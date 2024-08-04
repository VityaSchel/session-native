import Foundation
import SwiftUI
import SwiftData

struct NotificationsSettingsView: View {
  @Environment (\.modelContext) private var modelContext
  @EnvironmentObject private var userManager: UserManager
  @State private var notificationsEnabled: Bool = UserDefaults.standard.optionalBool(forKey: "notificationsEnabled") ?? true
  @Query(sort: \User.sessionId, order: .forward) private var users: [User]
  
  var body: some View {
    NavigationStack {
      VStack(alignment: .leading) {
        Button {
          withAnimation {
            notificationsEnabled.toggle()
          }
        } label: {
          Toggle(isOn: $notificationsEnabled.animation()) {
            HStack {
              Text("Enable notifications")
              Spacer()
            }
          }
          .toggleStyle(.switch)
          .padding(.all, 10)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color.cardBackground)
        .cornerRadius(8)
        Text("Receive notifications for users")
          .font(.system(size: 12).smallCaps())
          .foregroundStyle(Color.gray.opacity(0.75))
          .padding(.top, 11)
          .padding(.horizontal, 10)
        VStack(spacing: 0) {
          ForEach(Array(zip(users.indices, users)), id: \.0) { index, user in
            UserNotifications(user: user, disabled: !notificationsEnabled)
            if index < users.count - 1 {
              Divider()
            }
          }
        }
        .background(Color.cardBackground)
        .cornerRadius(8)
        Text("You can enable/disable push notifications per conversation.")
          .font(.system(size: 10))
          .foregroundStyle(Color.gray.opacity(0.75))
          .padding(.top, 1)
          .padding(.horizontal, 16)
      }
      .padding()
      .onChange(of: notificationsEnabled) {
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

struct UserNotifications: View {
  var user: User
  @State private var notificationsEnabled: Bool
  var disabled: Bool
  
  init(user: User, disabled: Bool) {
    self.user = user
    self.notificationsEnabled = UserDefaults.standard.optionalBool(forKey: "notificationsEnabled_" + user.id.uuidString) ?? true
    self.disabled = disabled
  }
  
  var body: some View {
    Button {
      withAnimation {
        notificationsEnabled.toggle()
      }
    } label: {
      Toggle(isOn: $notificationsEnabled.animation()) {
        HStack {
          Avatar(avatar: user.avatar, width: 24, height: 24)
          Text(user.displayName ?? getSessionIdPlaceholder(sessionId: user.sessionId))
          Spacer()
        }
      }
      .toggleStyle(.switch)
      .padding(.all, 10)
      .contentShape(Rectangle())
    }
//    .if(disabled) {
//      $0.disabled(true)
//    }
    .buttonStyle(.plain)
    .onChange(of: notificationsEnabled) {
      UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled_" + user.id.uuidString)
    }
  }
}

#Preview {
  SettingsView_Preview.previewWithTab("notifications")
}
