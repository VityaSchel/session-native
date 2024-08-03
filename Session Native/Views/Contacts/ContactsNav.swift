import Foundation
import SwiftUI
import SwiftData

struct ContactsNav: View {
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject var userManager: UserManager
  @EnvironmentObject var navigationManager: ViewManager
  @Query private var items: [Contact]
  @State private var searchText = ""
  
  init(userManager: UserManager) {
    let activeUserId = userManager.activeUser!.persistentModelID
    let predicate = #Predicate<Contact> {
      $0.user.persistentModelID == activeUserId
    }
    _items = Query(
      filter: predicate,
      sort: [SortDescriptor(\Contact.addedAt, order: .reverse)]
    )
  }
  
  var body: some View {
    if navigationManager.searchVisible {
      SearchField(searchText: $searchText)
        .padding(.horizontal, 12)
      Divider()
    }
    List(items.filter { contact in
      guard !searchText.isEmpty else {
        return true
      }
      let query = searchText.lowercased()
      if let name = contact.name {
        return name.lowercased().contains(query)
      } else if let displayName = contact.recipient.displayName {
        return displayName.lowercased().contains(query)
      } else {
        return contact.recipient.sessionId.contains(query)
      }
    }, selection: $navigationManager.navigationSelection) { item in
      ContactItem(contact: item)
    }
    .onChange(of: navigationManager.navigationSelection) {
      if (navigationManager.navigationSelection != "add_contact" && navigationManager.navigationSelection != nil) {
        do {
          if let contactIdString = navigationManager.navigationSelection {
            if(navigationManager.appView == .contacts) {
              if let contactId = UUID(uuidString: contactIdString) {
                var contactsFetchDescriptor = FetchDescriptor<Contact>(predicate: #Predicate { contact in
                  contact.id == contactId
                })
                contactsFetchDescriptor.fetchLimit = 1
                let contacts = try modelContext.fetch(contactsFetchDescriptor)
                if !contacts.isEmpty {
                  navigationManager.setActiveView(.conversations)
                  DispatchQueue.main.async {
                    if let conversation = contacts[0].conversation {
                      navigationManager.setActiveNavigationSelection(conversation.id.uuidString)
                    } else {
                      navigationManager.setActiveNavigationSelection("new", [
                        "recipient": contacts[0].recipient.sessionId
                      ])
                    }
                  }
                }
              }
            }
          }
          navigationManager.setActiveNavigationSelection(nil)
        } catch {
          print("Failed to load Contact model.")
        }
      }
    }
  }
}
