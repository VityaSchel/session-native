import Foundation
import SwiftUI
import SwiftData

struct NewConversationView: View {
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var viewManager: ViewManager
  @State private var text: String = ""
  @State private var error: String = ""
  @State private var submitting: Bool = false
  @FocusState private var inputFocused: Bool
  
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
  }
  
  private func handleSubmit() {
    if(text.count == 66) {
      openConversation(text)
    } else {
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
    }
  }
  
  private func openConversation(_ sessionId: String) {
    do {
      var fetchDescriptor = FetchDescriptor<Conversation>(predicate: #Predicate { conversation in
        conversation.recipient.sessionId == sessionId
      })
      fetchDescriptor.fetchLimit = 1
      
      let conversations = try modelContext.fetch(fetchDescriptor)
      
      if(!conversations.isEmpty) {
        viewManager.setActiveNavigationSelection(conversations[0].recipient.sessionId)
      } else {
        Task { @MainActor in
          let recipient = Recipient(
            id: UUID(),
            sessionId: sessionId
          )
          modelContext.insert(recipient)
          let conversation = Conversation(
            id: UUID(),
            recipient: recipient,
            archived: false,
            lastMessage: nil,
            typingIndicator: false
          )
          modelContext.insert(conversation)
          try modelContext.save()
          viewManager.setActiveNavigationSelection(conversation.id.uuidString)
        }
      }
    } catch {
      print("Failed to load Movie model.")
    }
  }
}

struct NewConversationView_Preview: PreviewProvider {
  static var previews: some View {
    let inMemoryModelContainer: ModelContainer = {
      do {
        let container = try ModelContainer(for: Schema(storageSchema), configurations: [.init(isStoredInMemoryOnly: true)])
        let convos = getConversationsPreviewMocks()
        container.mainContext.insert(convos[0])
        container.mainContext.insert(convos[1])
        container.mainContext.insert(convos[2])
        let users = getUsersPreviewMocks()
        container.mainContext.insert(users[0])
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
