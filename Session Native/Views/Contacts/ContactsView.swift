import SwiftUI
import SwiftData
import Combine

struct ContactsView: View {
  @EnvironmentObject private var viewManager: ViewManager
  
  var body: some View {
    if(viewManager.navigationSelection == "add_contact") {
      NewContactView()
    } else {
      VStack(spacing: 16) {
        Image(systemName: "person.crop.circle")
          .resizable()
          .scaledToFit()
          .frame(width: 64, height: 64)
        Text("Contacts is a list of recipients that you frequently communicate with. You can change their display names locally: right click on a contact and select «􀈊 Edit name».")
          .font(.caption)
          .multilineTextAlignment(.center)
      }
      .frame(width: 300)
      .padding()
    }
  }
}

struct ContactItem: View {
  @Environment (\.modelContext) private var context
  var contact: Contact
  @State private var isEditing = false
  @State private var name = ""
  
  var body: some View {
    NavigationLink(
      value: contact.id.uuidString
    ) {
      Avatar(avatar: contact.recipient.avatar)
      VStack {
        Text(contact.name ?? contact.recipient.displayName ?? getSessionIdPlaceholder(sessionId: contact.recipient.sessionId))
      }
    }
    .contextMenu(ContextMenu(menuItems: {
      Button("􀈊 Edit name") {
        isEditing = true
      }
      Divider()
      Button("􀁠 Remove from contacts") {
        context.delete(contact)
      }
    }))
    .popover(isPresented: $isEditing, arrowEdge: .trailing) {
      HStack(spacing: 6) {
        TextField("Display name (optional)", text: $name)
          .onSubmit {
            handleSubmit()
          }
          .textFieldStyle(.roundedBorder)
          .onReceive(Just(name)) { _ in limitText(64) }
          .frame(width: 200)
        Button("OK") {
          handleSubmit()
        }
      }
      .padding(.all, 8)
    }
    .onAppear {
      name = contact.name ?? ""
    }
  }
  
  func limitText(_ upper: Int) {
    if name.count > upper {
      name = String(name.prefix(upper))
    }
  }
  
  func handleSubmit() {
    isEditing = false
    withAnimation {
      do {
        contact.name = name.isEmpty ? nil : name
        try context.save()
      } catch {
        print("Failed to save contact name.")
      }
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
