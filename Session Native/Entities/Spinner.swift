import Foundation
import SwiftUI

enum SpinnerStyle {
  case dark
  case light
}

struct Spinner: View {
  @State private var isAnimating: Bool = false
  var style: SpinnerStyle
  var size: CGFloat = 12
  
  var body: some View {
    ZStack {
      Circle()
        .stroke(style == .dark ? Color.gray.opacity(0.3) : Color.black.opacity(0.2), lineWidth: 2)
      
      Circle()
        .trim(from: 0, to: 0.6)
        .stroke(style == .dark ? Color.white : Color.black.opacity(0.8), lineWidth: 2)
        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
    }
    .frame(width: size, height: size)
    .onAppear {
      isAnimating = true
    }
  }
}

#Preview {
  VStack {
    Spinner(style: .dark)
      .previewLayout(.sizeThatFits)
      .padding()
    HStack {
      Spinner(style: .light)
        .previewLayout(.sizeThatFits)
        .padding()
    }
    .background(Color.accentColor)
  }
}
