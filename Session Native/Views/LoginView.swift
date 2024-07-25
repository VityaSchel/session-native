import Foundation
import SwiftUI

struct LoginView: View {
  @EnvironmentObject var appViewManager: ViewManager
  
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
    VStack(spacing: 24) {
      VStack {
        Text("Login")
          .font(.custom("Cy Grotesk", size: 32))
          .multilineTextAlignment(.center)
      }
    }
    .frame(minWidth: 600, minHeight: 400)
  }
}

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

#Preview {
  LoginView()
    .environmentObject(ViewManager())
}
