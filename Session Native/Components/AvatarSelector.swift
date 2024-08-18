import Foundation
import SwiftUI

struct AvatarSelector: View {
  @State var avatarFilePath: String?
  @Binding var avatar: Data?
  
  var body: some View {
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
            .foregroundStyle(Color.white)
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
}
