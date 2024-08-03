import Foundation
import SwiftUI

struct ContactsToolbar: ToolbarContent {
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject private var userManager: UserManager
  @EnvironmentObject private var viewManager: ViewManager
  
  var body: some ToolbarContent {
    ToolbarItem {
      Spacer()
    }
    ToolbarItem {
      Button {
        withAnimation {
          viewManager.searchVisible.toggle()
        }
      } label: {
        Label("Search", systemImage: "magnifyingglass")
      }
      .if(viewManager.searchVisible, { view in
        view
          .background(Color.accentColor)
          .cornerRadius(5)
      })
    }
    ToolbarItem {
      Button {
        if(viewManager.navigationSelection == "add_contact") {
          viewManager.setActiveNavigationSelection(nil)
        } else {
          viewManager.setActiveNavigationSelection("add_contact")
        }
      } label: {
        Label("Add contact", systemImage: "person.badge.plus")
      }
      .if(viewManager.navigationSelection == "add_contact", { view in
        view
          .background(Color.accentColor)
          .cornerRadius(5)
      })
    }
  }
}
