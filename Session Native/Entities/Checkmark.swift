import Foundation
import SwiftUI

struct CheckmarkShape: Shape {
  var double: Bool
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let width = rect.size.width
    let height = rect.size.height
    path.move(to: CGPoint(x: 0.125*width, y: 0.53125*height))
    path.addLine(to: CGPoint(x: 0.28125*width, y: 0.6875*height))
    path.addLine(to: CGPoint(x: 0.65625*width, y: 0.3125*height))
    if double {
      path.move(to: CGPoint(x: 0.5*width, y: 0.625*height))
      path.addLine(to: CGPoint(x: 0.5625*width, y: 0.6875*height))
      path.addLine(to: CGPoint(x: 0.9375*width, y: 0.3125*height))
    }
    return path
  }
}

enum CheckmarkStyle {
  case dark
  case light
}

struct Checkmark: View {
  var style: CheckmarkStyle
  var double: Bool = false
  var size: CGFloat = 24
  var thickness: CGFloat = 2
  
  var body: some View {
    CheckmarkShape(double: double)
      .stroke(style == .dark ? Color.blue : Color.black.opacity(0.9), lineWidth: thickness)
      .frame(width: size, height: size)
  }
}

#Preview {
  VStack(spacing: 0) {
    Checkmark(style: .dark)
      .previewLayout(.sizeThatFits)
      .padding()
    Checkmark(style: .dark, double: true)
      .previewLayout(.sizeThatFits)
      .padding()
    Checkmark(style: .light)
      .previewLayout(.sizeThatFits)
      .padding()
      .background(Color.accentColor)
    Checkmark(style: .light, double: true)
      .previewLayout(.sizeThatFits)
      .padding()
      .background(Color.accentColor)
  }
}
