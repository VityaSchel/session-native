import Foundation
import SwiftUI
import SwiftData

struct PrivacySettingsView: View {
  @Environment (\.modelContext) private var modelContext
  @EnvironmentObject private var userManager: UserManager
  @State private var autoarchiveNewChats: Bool = UserDefaults.standard.optionalBool(forKey: "autoarchiveNewChats") ?? false
  @State private var autoacceptNewChats: Bool = UserDefaults.standard.optionalBool(forKey: "autoacceptNewChats") ?? false
  @State private var showTypingIndicatorsByDefault: Bool = UserDefaults.standard.optionalBool(forKey: "showTypingIndicatorsByDefault") ?? true
  @State private var sendReadCheckmarksByDefault: Bool = UserDefaults.standard.optionalBool(forKey: "sendReadCheckmarksByDefault") ?? true
  @State private var blockedUsers: [Conversation] = []
  @State private var blockedRecipientsSubview: Bool = false
  
  var body: some View {
    NavigationStack {
      VStack(alignment: .leading) {
        BlockedRecipientsButton(blockedUsersCount: blockedUsers.count) {
          withAnimation {
            blockedRecipientsSubview = true
          }
        }
        SettingsSection(title: "New chats") {
          SettingToggle(
            title: "Autoarchive new chats",
            isOn: $autoarchiveNewChats
          )
          Divider().padding(.horizontal, 8)
          SettingToggle(
            title: "Autoaccept new chats",
            isOn: $autoacceptNewChats
          )
          Divider().padding(.horizontal, 8)
          SettingToggle(
            title: "Show typing indicators",
            isOn: $showTypingIndicatorsByDefault
          )
          Divider().padding(.horizontal, 8)
          SettingToggle(
            title: "Send read checkmarks",
            isOn: $sendReadCheckmarksByDefault
          )
        }
        Text("You can enable/disable sending typing indicators and read receipts per conversation in recipient's profile settings.")
          .font(.system(size: 10))
          .foregroundStyle(Color.gray.opacity(0.75))
          .padding(.top, 1)
          .padding(.horizontal, 16)
      }
      .padding()
      .onChange(of: autoarchiveNewChats) {
        UserDefaults.standard.set(autoarchiveNewChats, forKey: "autoarchiveNewChats")
      }
      .onChange(of: autoacceptNewChats) {
        UserDefaults.standard.set(autoacceptNewChats, forKey: "autoacceptNewChats")
      }
      .onChange(of: showTypingIndicatorsByDefault) {
        UserDefaults.standard.set(showTypingIndicatorsByDefault, forKey: "showTypingIndicatorsByDefault")
      }
      .onChange(of: sendReadCheckmarksByDefault) {
        UserDefaults.standard.set(sendReadCheckmarksByDefault, forKey: "sendReadCheckmarksByDefault")
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .onAppear {
        loadBlockedUsersCount()
      }
      .navigationDestination(isPresented: $blockedRecipientsSubview) {
        BlockedRecipientsView(blockedUsers: $blockedUsers)
      }
    }
  }
  
  private func loadBlockedUsersCount() {
    if let activeUserId = userManager.activeUser?.persistentModelID {
      do {
        let fetchDescriptor = FetchDescriptor<Conversation>(predicate: #Predicate<Conversation> { conversation in
          conversation.user.persistentModelID == activeUserId
          && conversation.blocked == true
        })
        blockedUsers = try modelContext.fetch(fetchDescriptor)
      } catch {
        print("Error fetching blocked users: \(error)")
      }
    }
  }
}

struct BlockedRecipientsButton: View {
  @EnvironmentObject var userManager: UserManager
  let blockedUsersCount: Int
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        (
          Text("Blocked recipients for ") +
          Text(userManager.activeUser!.displayName ?? getSessionIdPlaceholder(sessionId: userManager.activeUser!.sessionId))
            .fontWeight(.semibold)
        )
        Spacer()
        Text(String(blockedUsersCount))
        Image(systemName: "chevron.right")
      }
      .padding(.all, 10)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .background(Color.cardBackground)
    .cornerRadius(8)
  }
}

struct SettingsSection<Content: View>: View {
  let title: String
  let content: Content
  
  init(title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.system(size: 12).smallCaps())
        .foregroundStyle(Color.gray.opacity(0.75))
        .padding(.top, 11)
        .padding(.horizontal, 10)
      VStack(alignment: .leading, spacing: 0) {
        content
      }
      .background(Color.cardBackground)
      .cornerRadius(8)
    }
  }
}

struct SettingToggle: View {
  let title: String
  @Binding var isOn: Bool
  
  var body: some View {
    Button {
      withAnimation {
        isOn.toggle()
      }
    } label: {
      Toggle(isOn: $isOn.animation()) {
        HStack {
          Text(title)
          Spacer()
        }
      }
      .toggleStyle(.switch)
      .padding(.all, 10)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}

struct BlockedRecipientsView: View {
  @EnvironmentObject var userManager: UserManager
  @Binding var blockedUsers: [Conversation]
  
  var body: some View {
    Group {
      if blockedUsers.count > 0 {
        ScrollView {
          VStack(spacing: 0) {
            ForEach(Array(zip(blockedUsers.indices, blockedUsers)), id: \.0) { index, conversation in
              Button {
                withAnimation {
                  conversation.blocked = false
                  blockedUsers.remove(at: index)
                }
              } label: {
                HStack {
                  Avatar(avatar: conversation.recipient.avatar, width: 24, height: 24)
                  Text(conversation.contact?.name ?? conversation.recipient.displayName ?? getSessionIdPlaceholder(sessionId: conversation.recipient.sessionId))
                  Spacer()
                  Text("Unblock")
                }
                .padding(.all, 10)
                .contentShape(Rectangle())
              }
              .buttonStyle(.plain)
              if index < blockedUsers.count - 1 {
                Divider()
              }
            }
          }
          .background(Color.cardBackground)
          .cornerRadius(8)
          .padding()
        }
      } else {
        Text("No blocked recipients")
          .font(.title3)
      }
    }
    .navigationTitle("Blocked recipients for " + (userManager.activeUser!.displayName ?? getSessionIdPlaceholder(sessionId: userManager.activeUser!.sessionId)))
  }
}

#Preview {
  SettingsView_Preview.previewWithTab("privacy")
}
