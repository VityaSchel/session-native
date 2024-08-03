import Foundation
import SwiftUI

struct SettingsToolbar: ToolbarContent {
  @EnvironmentObject var viewManager: ViewManager
  
  var body: some ToolbarContent {
    ToolbarItem {
      Spacer()
    }
    ToolbarItem {
      Button(action: {
        viewManager.setActiveNavigationSelection("profile")
      }) {
        Text("Edit")
      }
      .buttonStyle(.link)
    }
  }
}
