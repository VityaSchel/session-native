import Foundation
import SwiftUI

enum TypingIndicatorStyle {
  case dark
  case light
}

struct TypingIndicatorView: View {
  public var style: TypingIndicatorStyle = .dark
  var staticView = false
  @State private var animate = false
  var size: CGFloat = 10
  
  var body: some View {
    HStack(alignment: .center, spacing: size / 2) {
      ForEach(0..<3) { index in
        Circle()
          .frame(width: size, height: size)
          .foregroundColor(style == .dark ? .gray : Color.black.opacity(0.6))
          .opacity(self.animate ? 0.3 : 1)
          .animation(
            Animation.easeInOut(duration: 0.8)
              .repeatForever()
              .delay(Double(index) * 0.3),
            value: animate
          )
      }
    }
    .onAppear {
      self.animate = !staticView
    }
  }
}

#Preview {
  TypingIndicatorView()
    .frame(width: 50, height: 10)
    .previewLayout(.sizeThatFits)
    .padding()
}
