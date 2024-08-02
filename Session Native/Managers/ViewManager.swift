import SwiftData
import Combine
import SwiftUI

@MainActor
class ViewManager: ObservableObject {
  @Published var appView: AppView
  @Published var navigationSelection: String? = nil
  @Published var navigationSelectionData: [String: String]? = nil
  @Published var searchVisible = false
  
  init(_ defaultAppView: AppView? = nil, _ defaultNavigationSelection: String? = nil) {
    appView = defaultAppView ?? .auth
    navigationSelection = defaultNavigationSelection
  }
  
  func setActiveView(_ view: AppView) {
    if(appView != view) {
      appView = view
      self.navigationSelection = nil
      self.searchVisible = false
    }
  }
  
  func setActiveNavigationSelection(_ selection: String? = nil, _ data: [String: String]? = nil) {
    navigationSelection = selection
    navigationSelectionData = data
  }
}
