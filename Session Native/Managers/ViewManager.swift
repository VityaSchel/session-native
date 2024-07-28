import SwiftData
import Combine
import SwiftUI

@MainActor
class ViewManager: ObservableObject {
  @Published var appView: AppView
  
  init(_ defaultAppView: AppView? = nil) {
    appView = defaultAppView ?? .auth
  }
  
  func setActiveView(_ view: AppView) {
    withAnimation {
      appView = view
    }
  }
}
