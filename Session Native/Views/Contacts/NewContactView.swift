import Foundation
import SwiftUI
import SwiftData

struct NewContactView: View {
  @Environment (\.modelContext) private var modelContext
  @EnvironmentObject var navigationManager: ViewManager
  @EnvironmentObject var userManager: UserManager
  @State var contactSessionId: String = ""
  @State var contactDisplayName: String = ""
  @State var sessionIdError: Bool = false
  @State var displayNameError: Bool = false
  
  var body: some View {
    VStack(spacing: 4) {
      Text("Add contact")
        .font(.title)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .leading)
      TextField("Session ID", text: $contactSessionId)
        .padding(.top, 24)
      if sessionIdError {
        Text("Invalid Session ID")
          .fontWeight(.medium)
          .foregroundStyle(Color.red)
      }
      TextField("Display name (optional)", text: $contactDisplayName)
      if displayNameError {
        Text("Display name must be less than 64 characters")
          .fontWeight(.medium)
          .foregroundStyle(Color.red)
      }
      PrimaryButton("Add contact") {
        sessionIdError = false
        displayNameError = false
        if(contactSessionId.count != 66 || !isSessionID(contactSessionId)) {
          sessionIdError = true
        }
        if(contactDisplayName.count > 64) {
          displayNameError = true
        }
        if(sessionIdError == false && displayNameError == false) {
          addContact()
          contactSessionId = ""
          contactDisplayName = ""
        }
      }
      .padding(.top, 12)
    }
    .frame(width: 200)
    .padding(.horizontal, 24)
  }
  
  private func addContact() {
    guard !contactSessionId.isEmpty else {
      return
    }
    ContactsManager(
      context: modelContext,
      userManager: userManager
    )
      .addToContacts(sessionId: contactSessionId, name: contactDisplayName)
    navigationManager.setActiveNavigationSelection(nil)
  }
}
