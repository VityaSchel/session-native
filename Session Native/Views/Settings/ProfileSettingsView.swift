import Foundation
import SwiftUI

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
              mnemonic = nil
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
        displayName = user.displayName ?? ""
        avatar = user.avatar
      })
      .padding(.all, 24)
      .toolbar {
        ToolbarItem {
          Button(action: {
            user.displayName = displayName
            user.avatar = avatar
            request([
              "type": "set_session",
              "mnemonic": .string(readStringFromKeychain(account: user.sessionId, service: "mnemonic") ?? ""),
              "displayName": .string(displayName)
            ])
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

#Preview {
  SettingsView_Preview.previews
}

