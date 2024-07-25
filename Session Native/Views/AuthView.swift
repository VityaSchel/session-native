import Foundation
import SwiftUI

struct AuthView: View {
  @EnvironmentObject var appViewManager: ViewManager
  
  var body: some View {
    VStack(spacing: 24) {
      VStack(spacing: -8) {
        Text("Welcome to")
          .font(.custom("Cy Grotesk", size: 32))
          .multilineTextAlignment(.center)
        Text("Session Native")
          .font(.custom("Cy Grotesk", size: 38))
          .multilineTextAlignment(.center)
          .foregroundColor(.accent)
      }
      VStack(spacing: 8) {
        PrimaryButton("Create Session") {
          appViewManager.setActiveView(.signup)
        }
        SecondaryButton("I'm already registered") {
          appViewManager.setActiveView(.login)
        }
      }
    }
    .frame(minWidth: 600, minHeight: 400)
  }
}

#Preview {
  AuthView()
    .environmentObject(ViewManager())
}
