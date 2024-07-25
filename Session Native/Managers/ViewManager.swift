import SwiftData
import Combine
import SwiftUI

@MainActor
class ViewManager: ObservableObject {
  @Published var appView: AppView = .auth
  
  init() {
    // todo: check whether the user is logged in with saved credentials
  }
  
  func setActiveView(_ view: AppView) {
    withAnimation {
      appView = view
    }
  }
}
