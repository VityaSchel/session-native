import Foundation
import SwiftUI
import Combine

struct SignupView: View {
  @EnvironmentObject var appViewManager: ViewManager
  @EnvironmentObject var userManager: UserManager
  @State private var avatarFilePath: String?
  @State private var avatar: Data? = nil
  @State private var displayName: String = ""
  @State private var sessionId: String = ""
  @State private var mnemonic: String = ""
  
  var body: some View {
    VStack(spacing: 0) {
      VStack {
        Text("Create Session")
          .font(.custom("Cy Grotesk", size: 32))
          .multilineTextAlignment(.center)
      }
      .padding(.bottom, 48)
      Text("Introducing your Session ID:")
        .font(.title2)
      SessionIdAnimation(finalString: sessionId)
      HStack(spacing: 24) {
        AvatarSelector(avatar: $avatar)
        TextField("Profile name (optional)", text: $displayName)
          .textFieldStyle(.plain)
          .onReceive(Just(displayName)) { _ in limitText(64) }
          .onSubmit {
            signup()
          }
      }
      .padding(.top, 24)
      .frame(maxWidth: 385)
      HStack {
        Button(action: {
          signup()
        }) {
          Text("Save")
            .padding(6)
        }
        .buttonStyle(.borderedProminent)
      }
      .frame(maxWidth: 385)
      .padding(.top, 32)
    }
    .frame(minWidth: 600, minHeight: 400)
    .onAppear {
      request(["type": "generate_session"]) { response in
        if let sessionId = response["sessionId"]?.stringValue,
           let mnemonic = response["mnemonic"]?.stringValue {
          self.sessionId = sessionId
          self.mnemonic = mnemonic
        }
      }
    }
  }
  
  func limitText(_ upper: Int) {
    if displayName.count > upper {
      displayName = String(displayName.prefix(upper))
    }
  }
  
  private func signup() {
    let result = saveToKeychain(account: sessionId, service: "mnemonic", data: mnemonic.data(using: .utf8)!)
    if(result == errSecSuccess) {
      let user = User(id: UUID(), sessionId: sessionId, displayName: displayName.count == 0 ? nil : displayName, avatar: avatar)
      userManager.addUser(user, mnemonic: mnemonic, onCompletion: {
        appViewManager.setActiveView(.conversations)
      })
    }
  }
}

#Preview {
  SignupView()
    .environmentObject(ViewManager())
}
