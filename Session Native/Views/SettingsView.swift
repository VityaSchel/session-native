import SwiftUI
import SwiftData

struct SettingsView: View {
  @EnvironmentObject var viewManager: ViewManager
  
  var body: some View {
    ScrollView {
      switch(viewManager.navigationSelection) {
      case "profile":
        ProfileSettingsView()
      case "general":
        GeneralSettingsView()
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
      viewManager.setActiveNavigationSelection("profile")
    }
  }
}

struct ProfileSettingsView: View {
  @Environment(\.modelContext) var modelContext
  @State var avatar: Data?
  @State var displayName = ""
  @EnvironmentObject var userManager: UserManager
  @EnvironmentObject var viewManager: ViewManager
  @State var mnemonic: String?
  @State var mnemonicWarningVisible = false
  @State var mnemonicPlaceholder: String = ""
  @State var logoutWarningVisible = false
  
  var body: some View {
    if let user = userManager.activeUser {
      VStack(alignment: .leading) {
        HStack(spacing: 14) {
          AvatarSelector(avatar: $avatar)
          TextField("Display name (optional)", text: $displayName)
            .textFieldStyle(.plain)
        }
        .padding(.all, 10)
        .background(Color.cardBackground)
        .cornerRadius(8)
        Spacer()
          .frame(height: 24)
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            Text(user.sessionId)
              .font(.system(size: 11, design: .monospaced))
              .textSelection(.enabled)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 10)
          .padding(.top, 10)
          .padding(.bottom, 7)
          Divider()
          Button {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(user.sessionId, forType: .string)
          } label: {
            Label("Copy Session ID", systemImage: "doc.on.doc")
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 14)
              .padding(.top, 8)
              .padding(.bottom, 10)
              .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
        .background(Color.cardBackground)
        .cornerRadius(8)
        Text("Session ID is a unique identifier for your account. Anyone can use it to start conversation with you.")
          .font(.system(size: 10))
          .foregroundStyle(Color.gray.opacity(0.75))
          .padding(.top, 1)
          .padding(.bottom, 24)
          .padding(.horizontal, 16)
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            Text(mnemonic ?? mnemonicPlaceholder)
              .font(.system(size: 11, design: .monospaced))
              .if(mnemonic != nil) { view in
                view.textSelection(.enabled)
                  .privacySensitive()
              }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 10)
          .padding(.top, 10)
          .padding(.bottom, 7)
          Divider()
          Button {
            if(mnemonic == nil) {
              mnemonicWarningVisible = true
            } else {
              mnemonicWarningVisible = false
            }
          } label: {
            Label(mnemonic == nil ? "Reveal mnemonic" : "Hide mnemonic", systemImage: mnemonic == nil ? "eye" : "eye.slash")
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 14)
              .padding(.top, 8)
              .padding(.bottom, 10)
              .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .alert(isPresented: $mnemonicWarningVisible) {
            Alert(
              title: Text("DO NOT SHARE THIS PHRASE"),
              message: Text("Are you sure you want to reveal this mnemonic? Please make sure no one is watching your screen and nothing records it, there is no way to reset your mnemonic. These 13 words give full access to your Session, including message history and ability to send messages."),
              primaryButton: .default(Text("Reveal")) {
                mnemonic = readStringFromKeychain(account: user.sessionId, service: "mnemonic")
              },
              secondaryButton: .cancel()
            )
          }
        }
        .background(Color.cardBackground)
        .cornerRadius(8)
        (Text("Mnemonic or seed phrase is a secret key to access your Session. ") + Text("Do not share it with anyone").fontWeight(.bold) + Text(" — this 13 words give full access to this account."))
          .font(.system(size: 10))
          .foregroundStyle(Color.gray.opacity(0.75))
          .padding(.top, 1)
          .padding(.horizontal, 16)
          .padding(.bottom, 18)
        HStack {
          Button {
            logoutWarningVisible = true
          } label: {
            Text("Remove this Session from this device")
              .padding(.vertical, 10)
              .padding(.horizontal, 14)
              .frame(maxWidth: .infinity, alignment: .leading)
              .contentShape(Rectangle())
          }
          .foregroundStyle(Color.red)
          .buttonStyle(.plain)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.cardBackground)
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
        .alert(isPresented: $logoutWarningVisible) {
          Alert(
            title: Text("Are you sure?"),
            message: Text("After pressing log out, all data of this account will be deleted locally. If you want to use this account again, make sure you backup your mnemonic."),
            primaryButton: .default(Text("Log out")) {
              do {
                modelContext.delete(user)
                try modelContext.save()
                let indexOfActiveUser = userManager.users.firstIndex(of: user)
                userManager.users.remove(at: indexOfActiveUser!)
                if(userManager.users.count > 0) {
                  let nextUser = userManager.users[0]
                  userManager.setActiveUser(nextUser)
                } else {
                  viewManager.setActiveView(.auth)
                  userManager.setActiveUser(nil)
                }
              } catch {
                print("Failed to delete user: \(error.localizedDescription)")
              }
            },
            secondaryButton: .cancel()
          )
        }
      }
      .onChange(of: user, {
        mnemonic = nil
        mnemonicPlaceholder = getRandomHiddenMnemonic()
      })
      .padding(.all, 24)
      .toolbar {
        ToolbarItem {
          Button(action: {
            do {
              user.displayName = displayName
              user.avatar = avatar
              try modelContext.save()
            } catch {
              print("Failed to save user")
            }
          }) {
            Text("Save")
          }
          .buttonStyle(.link)
        }
      }
      .onAppear(perform: {
        mnemonicPlaceholder = getRandomHiddenMnemonic()
        displayName = user.displayName ?? ""
        avatar = user.avatar
      })
    }
  }
  
  func getRandomHiddenMnemonic() -> String {
    var result = [String]()
    for _ in 0..<13 {
      let starCount = Int.random(in: 3...6)
      let stars = String(repeating: "*", count: starCount)
      result.append(stars)
    }
    return result.joined(separator: " ")
  }
}

struct GeneralSettingsView: View {
  var body: some View {
    VStack {
      // TODO: general settings
    }
  }
}

struct NotificationsSettingsView: View {
  var body: some View {
    VStack {
      // TODO: notifications settings
    }
  }
}

struct PrivacySettingsView: View {
  var body: some View {
    VStack {
      // TODO: privacy settings
    }
  }
}

struct AppearanceSettingsView: View {
  var body: some View {
    VStack {
      // TODO: appearance settings
      // TODO: check light theme
    }
  }
}

struct HelpView: View {
  var body: some View {
    VStack {
      // TODO: help section in settings
    }
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
            Text("Notifications & sound")
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
