import Foundation
import SwiftUI

struct Avatar: View {
  var avatar: Data?
  
  var body: some View {
    ZStack {
      if let avatarData = avatar, let nsImage = NSImage(data: avatarData) {
        Image(nsImage: nsImage)
          .resizable()
      }
      Image(systemName: "person.fill")
        .resizable()
        .scaledToFit()
        .padding(12)
    }
    .frame(width: 40, height: 40)
    .background(Color.gray.gradient)
    .cornerRadius(.infinity)
  }
}

#Preview {
  Avatar(avatar: nil)
}
