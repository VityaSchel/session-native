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
    HStack {
      Button(action: {
        appViewManager.setActiveView(.auth)
      }) {
        Image(systemName: "chevron.backward")
      }
      .buttonStyle(ToolbarButtonStyle())
      Spacer()
    }
    .padding(.top, 7)
    .padding(.horizontal, 12)
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
        Button(action: {
          avatarFilePath = nil
          openAvatarPicker()
        }) {
          ZStack {
            if let avatarData = avatar, let nsImage = NSImage(data: avatarData) {
              Image(nsImage: nsImage)
                .resizable()
                .scaledToFill()
                .aspectRatio(contentMode: .fill)
            } else {
              Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .padding(18)
            }
          }
          .frame(width: 64, height: 64)
          .background(Color.gray.gradient)
          .cornerRadius(.infinity)
        }
        .contentShape(Circle())
        .buttonStyle(.borderless)
        .clipShape(Circle())
        .cornerRadius(.infinity)
        TextField("Profile name (optional)", text: $displayName)
          .textFieldStyle(.plain)
          .onReceive(Just(displayName)) { _ in limitText(64) }
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
  
  private func openAvatarPicker() {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    openPanel.allowsMultipleSelection = false
    openPanel.allowedContentTypes = [.image]
    
    if openPanel.runModal() == .OK, let url = openPanel.url {
      avatarFilePath = url.path
      loadImageData(from: url)
    }
  }
  
  private func loadImageData(from url: URL) {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let data = try Data(contentsOf: url)
        DispatchQueue.main.async {
          avatar = data
        }
      } catch {
        print("Error loading image data: \(error)")
      }
    }
  }
  
  private func signup() {
    let result = saveToKeychain(account: sessionId, service: "mnemonic", data: mnemonic.data(using: .utf8)!)
    if(result == errSecSuccess) {
      let user = User(id: UUID(), sessionId: sessionId, displayName: displayName, avatar: avatar)
      userManager.addUser(user)
      userManager.setActiveUser(user)
      userManager.saveUsers()
      appViewManager.setActiveView(.conversations)
    }
  }
}

#Preview {
  SignupView()
    .environmentObject(ViewManager())
}
