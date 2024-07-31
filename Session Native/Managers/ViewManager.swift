import SwiftData
import Combine
import SwiftUI

@MainActor
class ViewManager: ObservableObject {
  @Published var appView: AppView
  @Published var navigationSelection: String? = nil
  
  init(_ defaultAppView: AppView? = nil, _ defaultNavigationSelection: String? = nil) {
    appView = defaultAppView ?? .auth
    navigationSelection = defaultNavigationSelection
  }
  
  func setActiveView(_ view: AppView) {
    if(appView != view) {
      appView = view
      self.navigationSelection = nil
    }
  }
  
  func setActiveNavigationSelection(_ selection: String? = nil) {
    navigationSelection = selection
  }
}