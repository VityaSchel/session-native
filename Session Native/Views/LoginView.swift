import Foundation
import SwiftUI
import Combine

struct LoginView: View {
  @EnvironmentObject var appViewManager: ViewManager
  @EnvironmentObject var userManager: UserManager
  @State var mnemonic: String = ""
  @State var derivedSessionId: String? = nil
  @State var errorMessage: String? = nil
  
  var body: some View {
    VStack(spacing: 24) {
      VStack {
        Text("Login")
          .font(.custom("Cy Grotesk", size: 32))
          .multilineTextAlignment(.center)
        TextField("13-words mnemonic", text: $mnemonic)
          .padding(.bottom, 24)
          .onReceive(Just(mnemonic)) { _ in formatMnemonic() }
        HStack(spacing: 18) {
          if let sessionId = derivedSessionId {
            VStack(alignment: .leading) {
              Text("You're logging in as")
                .font(.caption)
              Text(sessionId.prefix(6))
                .fontWeight(.medium)
                .font(.system(size: 13, design: .monospaced))
              +
              Text("...")
              +
              Text(sessionId.suffix(6))
                .fontWeight(.medium)
                .font(.system(size: 13, design: .monospaced))
            }
            Button(action: {
              login()
            }) {
              Text("Save")
                .frame(width: 155)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
          } else {
            if let errorMessageUnwrapped = errorMessage {
              Text(errorMessageUnwrapped)
                .font(.system(size: 16, weight: .medium))
                .frame(height: 24.5)
                .foregroundStyle(Color.red)
            } else {
              Text(String(mnemonic.split(separator: " ").count) + "/13")
                .font(.system(size: 16, design: .monospaced))
                .frame(height: 24.5)
            }
          }
        }
      }
      .frame(width: 300)
    }
    .frame(minWidth: 600, minHeight: 400)
  }
  
  func formatMnemonic() {
    let words = mnemonic
        .lowercased()
        .replacingOccurrences(
          of: "[^a-z ]",
          with: "",
          options: [.regularExpression]
        )
        .split(separator: " ")
    let endsWithSpace = mnemonic.last == " "
    mnemonic = words.prefix(min(words.count, 13))
      .joined(separator: " ") + ((endsWithSpace && words.count < 13) ? " " : "")
    
    if(words.count == 13) {
      request([
        .string("type"): .string("mnemonic_to_session_id"),
        .string("mnemonic"): .string(mnemonic),
      ], { response in
        if(response["ok"]?.boolValue == true) {
          derivedSessionId = response["sessionId"]?.stringValue
        } else {
          errorMessage = "Invalid mnemonic"
        }
      })
    } else {
      errorMessage = nil
      derivedSessionId = nil
    }
  }
  
  private func login() {
    let result = saveToKeychain(account: derivedSessionId!, service: "mnemonic", data: mnemonic.data(using: .utf8)!)
    if(result == errSecSuccess) {
      let user = User(id: UUID(), sessionId: derivedSessionId!)
      userManager.addUser(user)
      userManager.setActiveUser(user)
      userManager.saveUsers()
      appViewManager.setActiveView(.conversations)
    }
  }
}

#Preview {
  LoginView()
    .environmentObject(ViewManager())
}
