import Foundation
import SwiftUI
import SwiftData

struct NewConversationView: View {
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var viewManager: ViewManager
  @EnvironmentObject var userManager: UserManager
  @State private var text: String = ""
  @State private var error: String = ""
  @State private var submitting: Bool = false
  @FocusState private var inputFocused: Bool
  @Namespace private var namespace
  
  var body: some View {
    VStack(spacing: 12) {
      TextField("Session ID or ONS", text: $text)
        .disabled(submitting)
        .onSubmit({
          handleSubmit()
        })
        .onChange(of: text, {
          error = ""
        })
        .focused($inputFocused, equals: true)
        .prefersDefaultFocus(in: self.namespace)
        .onChange(of: viewManager.navigationSelectionData) {
          if let data = viewManager.navigationSelectionData {
            if let recipient = data["recipient"] {
              text = recipient
            }
          }
        }
        .onAppear {
          if let data = viewManager.navigationSelectionData {
            if let recipient = data["recipient"] {
              text = recipient
            }
          }
        }
      if !error.isEmpty {
        Text(error)
          .fontWeight(.medium)
          .foregroundStyle(Color.red)
      }
      HStack(alignment: .top) {
        PrimaryButton("Open", width: 100) {
          handleSubmit()
        }
        .disabled(submitting)
        Spacer()
        VStack {
          (
            Text("Oxen Name System (ONS)")
              .fontWeight(.bold)
            + Text(" allows you to map your nickname to Session ID"))
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.trailing)
        }
      }
      .frame(width: 299)
    }
    .frame(width: 300)
    .navigationTitle("New conversation")
    .focusScope(self.namespace)
    .defaultFocus($inputFocused, true)
  }
  
  private func handleSubmit() {
    if(text.count == 66 && isSessionID(text)) {
      openConversation(text)
    } else {
      if(text.count <= 64) {
        submitting = true
        request([
          "type": "resolve_ons",
          "ons": .string(text)
        ], { response in
          submitting = false
          if(response["ok"]?.boolValue == true) {
            if(response["sessionId"]?.isNil == true) {
              error = "ONS not found"
              inputFocused = true
            } else {
              if let sessionId = response["sessionId"]?.stringValue {
                openConversation(sessionId)
              }
            }
          } else {
            error = response["error"]?.stringValue ?? "Error during ONS resolving"
            inputFocused = true
          }
        })
      } else {
        error = "Invalid ONS"
        inputFocused = true
      }
    }
  }
  
  private func openConversation(_ sessionId: String) {
    if let activeUserId = userManager.activeUser?.persistentModelID {
      do {
        var conversationFetchDescriptor = FetchDescriptor<Conversation>(predicate: #Predicate { conversation in
          conversation.recipient.sessionId == sessionId
          && conversation.user.persistentModelID == activeUserId
        })
        conversationFetchDescriptor.fetchLimit = 1
        let conversations = try modelContext.fetch(conversationFetchDescriptor)
        
        if(!conversations.isEmpty) {
          DispatchQueue.main.async {
            viewManager.setActiveNavigationSelection(conversations[0].id.uuidString)
          }
        } else {
          print(1)
          var recipientsFetchDescriptor = FetchDescriptor<Recipient>(predicate: #Predicate { recipient in
            recipient.sessionId == sessionId
          })
          recipientsFetchDescriptor.fetchLimit = 1
          let recipients = try modelContext.fetch(recipientsFetchDescriptor)
          let recipient: Recipient
          if(recipients.isEmpty) {
            recipient = Recipient(
              id: UUID(),
              sessionId: sessionId
            )
            modelContext.insert(recipient)
          } else {
            recipient = recipients[0]
          }
          
          print(2, recipient.sessionId)
          
          let conversation = Conversation(
            id: UUID(),
            user: userManager.activeUser!,
            recipient: recipient,
            archived: false,
            lastMessage: nil,
            typingIndicator: false
          )
          
          var contactsFetchDescriptor = FetchDescriptor<Contact>(predicate: #Predicate { contact in
            contact.recipient.sessionId == sessionId
            && contact.user.persistentModelID == activeUserId
          })
          contactsFetchDescriptor.fetchLimit = 1
          let contacts = try modelContext.fetch(contactsFetchDescriptor)
          if !contacts.isEmpty {
            conversation.contact = contacts[0]
          }
          modelContext.insert(conversation)
          try modelContext.save()
          DispatchQueue.main.async {
            viewManager.setActiveNavigationSelection(conversation.id.uuidString)
          }
        }
      } catch {
        print("Failed to save new conversation model.")
      }
    }
  }
}

struct NewConversationView_Preview: PreviewProvider {
  static var previews: some View {
    let inMemoryModelContainer: ModelContainer = {
      do {
        let container = try ModelContainer(for: Schema(storageSchema), configurations: [.init(isStoredInMemoryOnly: true)])
        let users = getUsersPreviewMocks()
        container.mainContext.insert(users[0])
        let convos = getConversationsPreviewMocks(user: users[0])
        container.mainContext.insert(convos[0])
        container.mainContext.insert(convos[1])
        container.mainContext.insert(convos[2])
        try container.mainContext.save()
        UserDefaults.standard.set(users[0].id.uuidString, forKey: "activeUser")
        return container
      } catch {
        fatalError("Could not create ModelContainer: \(error)")
      }
    }()
    
    NewConversationView()
      .modelContainer(inMemoryModelContainer)
      .environmentObject(ViewManager())
      .frame(width: 500, height: 300)
  }
}
