import Foundation
import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
  @State private var isHovering = false
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(width: 24, height: 24)
      .background(
        configuration.isPressed
        ? Color.gray.opacity(0.2)
        : isHovering
        ? Color.gray.opacity(0.1)
        : Color.clear
      )
      .foregroundColor(Color.gray.opacity(0.8))
      .cornerRadius(5)
      .contentShape(Rectangle())
      .onHover { hovering in
        isHovering = hovering
      }
  }
}
