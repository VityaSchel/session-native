import Foundation
import SwiftUI

struct Avatar: View {
  var avatar: Data?
  var width: CGFloat? = 40
  var height: CGFloat? = 40
  
  var body: some View {
    ZStack {
      if let avatarData = avatar, let nsImage = NSImage(data: avatarData) {
        Image(nsImage: nsImage)
          .resizable()
      }
      Image(systemName: "person.fill")
        .resizable()
        .scaledToFit()
        .padding((width ?? 40)*0.3)
    }
    .frame(width: width, height: height)
    .background(Color.gray.gradient)
    .cornerRadius(.infinity)
  }
}

#Preview {
  Avatar(avatar: nil)
}