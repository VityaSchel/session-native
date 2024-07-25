import Foundation
import SwiftUI

let buttonSize: CGFloat = 24.0

struct AppViewsNavigation: View {
  @Binding var appView: AppView
  
  var body: some View {
    HStack {
      Spacer()
      NavButton(appView: $appView, view: .contacts, icon: "person.crop.circle.fill")
      Spacer()
      Spacer()
      NavButton(appView: $appView, view: .conversations, icon: "bubble.left.and.bubble.right.fill")
      Spacer()
      Spacer()
      NavButton(appView: $appView, view: .settings, icon: "gear")
      Spacer()
    }
    .padding(.vertical, 12.5)
    .border(width: 1, edges: [.top], color: Color("Separator"))
    .background(.ultraThinMaterial)
  }
  
  private struct NavButton: View {
    @Binding var appView: AppView
    var view: AppView
    var icon: String
    
    var body: some View {
      Button(action: {
        appView = view
      }) {
        Image(systemName: icon)
          .resizable()
          .frame(width: buttonSize, height: buttonSize)
          
      }
      .foregroundColor(appView == view ? Color.accentColor : Color.gray)
      .buttonStyle(PlainButtonStyle())
    }
  }
}

#Preview {
  AppViewsNavigation(appView: .constant(.conversations))
}
