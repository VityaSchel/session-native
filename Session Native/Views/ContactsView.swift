import SwiftUI
import SwiftData

struct ContactsView: View {
  @EnvironmentObject private var viewManager: ViewManager
  
  var body: some View {
    if(viewManager.navigationSelection == "add_contact") {
      NewContact()
    } else {
      Text("TODO: There will be a tip for contacts")
    }
  }
}

struct NewContact: View {
  @Environment (\.modelContext) private var modelContext
  @EnvironmentObject var navigationManager: ViewManager
  @EnvironmentObject var userManager: UserManager
  @State var contactSessionId: String = ""
  @State var contactDisplayName: String = ""
  @State var sessionIdError: Bool = false
  @State var displayNameError: Bool = false
  
  var body: some View {
    VStack(spacing: 4) {
      Text("Contacts are list of recipients that you frequently communicate with. You can change their display names locally.")
        .font(.caption2)
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
    if let activeUserId = userManager.activeUser?.persistentModelID {
      do {
        var recipientsFetchDescriptor = FetchDescriptor<Recipient>(predicate: #Predicate { recipient in
          recipient.sessionId == contactSessionId
        })
        recipientsFetchDescriptor.fetchLimit = 1
        let recipients = try modelContext.fetch(recipientsFetchDescriptor)
        
        let contactRecipient: Recipient
        if(recipients.isEmpty) {
          contactRecipient = Recipient(
            id: UUID(),
            sessionId: contactSessionId,
            displayName: nil
          )
          modelContext.insert(contactRecipient)
        } else {
          contactRecipient = recipients[0]
        }
        
        let contact = Contact(id: UUID(), recipient: contactRecipient, name: contactDisplayName, user: userManager.activeUser!)
        modelContext.insert(contact)
        
        let recipientId = contactRecipient.persistentModelID
        var conversationsFetchDescriptor = FetchDescriptor<Conversation>(predicate: #Predicate { conversation in
          conversation.recipient.persistentModelID == recipientId
          && conversation.user.persistentModelID == activeUserId
        })
        conversationsFetchDescriptor.fetchLimit = 1
        let conversations = try modelContext.fetch(conversationsFetchDescriptor)
        if !conversations.isEmpty {
          contact.conversation = conversations[0]
        }
        
        try modelContext.save()
      } catch {
        print("Failed to load Recipient model.")
      }
    }
    navigationManager.setActiveNavigationSelection(nil)
  }
}

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
    SearchField(searchText: $searchText)
    Divider()
    List(items, selection: $navigationManager.navigationSelection) { item in
      NavigationLink(
        value: item.id.uuidString
      ) {
        Avatar(avatar: item.recipient.avatar)
        VStack {
          Text(item.name ?? item.recipient.displayName ?? getSessionIdPlaceholder(sessionId: item.recipient.sessionId))
        }
      }
    }
    .onChange(of: navigationManager.navigationSelection) {
      if (navigationManager.navigationSelection != "add_contact" && navigationManager.navigationSelection != nil) {
        do {
          if let contactIdString = navigationManager.navigationSelection,
             let activeUserId = userManager.activeUser?.persistentModelID {
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
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}

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

struct ContactsView_Preview: PreviewProvider {
  static var previews: some View {
    let inMemoryModelContainer: ModelContainer = {
      do {
        let container = try ModelContainer(for: Schema(storageSchema), configurations: [.init(isStoredInMemoryOnly: true)])
        let users = getUsersPreviewMocks()
        container.mainContext.insert(users[0])
        let contacts = getContactsPreviewMocks(user: users[0])
        container.mainContext.insert(contacts[0])
        container.mainContext.insert(contacts[1])
        container.mainContext.insert(contacts[2])
        try container.mainContext.save()
        UserDefaults.standard.set(users[0].id.uuidString, forKey: "activeUser")
        return container
      } catch {
        fatalError("Could not create ModelContainer: \(error)")
      }
    }()
    
    let userManager = UserManager(container: inMemoryModelContainer)
    
    return Group {
      NavigationSplitView {
        VStack {
          ContactsNav(userManager: userManager)
          AppViewsNavigation()
        }
        .toolbar {
          ContactsToolbar()
        }
        .frame(minWidth: 200)
        .toolbar(removing: .sidebarToggle)
      } detail: {
        ContactsView()
      }
    }
    .modelContainer(inMemoryModelContainer)
    .environmentObject(userManager)
    .environmentObject(ViewManager(.contacts))
  }
}
