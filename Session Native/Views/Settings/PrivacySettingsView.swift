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
        Button {
          withAnimation {
            blockedRecipientsSubview = true
          }
        } label: {
          HStack {
            Text("Blocked recipients")
            Spacer()
            Text(String(blockedUsers.count))
            Image(systemName: "chevron.right")
          }
          .padding(.all, 10)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color.cardBackground)
        .cornerRadius(8)
        Text("New chats")
          .font(.system(size: 12).smallCaps())
          .foregroundStyle(Color.gray.opacity(0.75))
          .padding(.top, 11)
          .padding(.horizontal, 10)
        VStack(spacing: 0) {
          Button {
            withAnimation {
              autoarchiveNewChats.toggle()
            }
          } label: {
            Toggle(isOn: $autoarchiveNewChats.animation()) {
              HStack {
                Text("Autoarchive new chats")
                Spacer()
              }
            }
            .toggleStyle(.switch)
            .padding(.all, 10)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          Divider().padding(.horizontal, 10)
          Button {
            withAnimation {
              autoacceptNewChats.toggle()
            }
          } label: {
            Toggle(isOn: $autoacceptNewChats.animation()) {
              HStack {
                Text("Autoaccept new chats")
                Spacer()
              }
            }
            .toggleStyle(.switch)
            .padding(.all, 10)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          Divider().padding(.horizontal, 10)
          Button {
            withAnimation {
              showTypingIndicatorsByDefault.toggle()
            }
          } label: {
            Toggle(isOn: $showTypingIndicatorsByDefault.animation()) {
              HStack {
                Text("Show typing indicators")
                Spacer()
              }
            }
            .toggleStyle(.switch)
            .padding(.all, 10)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          Divider().padding(.horizontal, 10)
          Button {
            withAnimation {
              sendReadCheckmarksByDefault.toggle()
            }
          } label: {
            Toggle(isOn: $sendReadCheckmarksByDefault.animation()) {
              HStack {
                Text("Send read checkmarks")
                Spacer()
              }
            }
            .toggleStyle(.switch)
            .padding(.all, 10)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
        .background(Color.cardBackground)
        .cornerRadius(8)
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
        if blockedUsers.count > 0 {
          ScrollView {
            List(blockedUsers) { user in
              Button {
                withAnimation {
                  blockedRecipientsSubview = true
                }
              } label: {
                HStack {
                  Text(user.contact?.name ?? user.recipient.displayName ?? user.recipient.sessionId)
                  Spacer()
                  Text("Unblock")
                }
                .padding(.all, 10)
                .contentShape(Rectangle())
              }
              .buttonStyle(.plain)
              .background(Color.cardBackground)
              .cornerRadius(8)
            }
          }
        } else {
          Text("No blocked recipients")
            .font(.title3)
        }
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

#Preview {
  SettingsView_Preview.previewWithTab("privacy")
}
