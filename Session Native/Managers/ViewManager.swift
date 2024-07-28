import SwiftData
import Combine
import SwiftUI

@MainActor
class ViewManager: ObservableObject {
  @Published var appView: AppView
  @Published var navigationSelection: String? = nil
  
  init(_ defaultAppView: AppView? = nil) {
    appView = defaultAppView ?? .auth
  }
  
  func setActiveView(_ view: AppView) {
    if(appView != view) {
      withAnimation {
        appView = view
      }
    }
  }
  
  func setActiveNavigationSelection(_ selection: String? = nil) {
    navigationSelection = selection
  }
}
