import Foundation
import SwiftUI
import Combine

struct SignupView: View {
  @EnvironmentObject var appViewManager: ViewManager
  @State private var avatar: Data? = nil
  @State private var displayName: String = ""
  @State private var showFileImporter = false
  
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
    .frame(width: .infinity, alignment: .leading)
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
      SessionIdAnimation(finalString: "05aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
      HStack(spacing: 24) {
        Button(action: {
          let panel = NSOpenPanel()
          panel.allowsMultipleSelection = false
          panel.canChooseDirectories = false
        }) {
          ZStack {
            if let avatarData = avatar, let nsImage = NSImage(data: avatarData) {
              Image(nsImage: nsImage)
                .resizable()
            }
            Image(systemName: "photo")
              .resizable()
              .scaledToFit()
              .padding(18)
          }
          .frame(width: 64, height: 64)
          .background(Color.gray.gradient)
          .cornerRadius(.infinity)
          .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
              print(url)
            case .failure(let error):
              print(error)
            }
          }
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
  }
  
  func limitText(_ upper: Int) {
    if displayName.count > upper {
      displayName = String(displayName.prefix(upper))
    }
  }
}

#Preview {
  SignupView()
    .environmentObject(ViewManager())
}
