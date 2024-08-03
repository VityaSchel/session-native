import Foundation
import SwiftData

class ContactsManager {
  private let modelContext: ModelContext
  private let userManager: UserManager
  
  init(context: ModelContext, userManager: UserManager) {
    self.modelContext = context
    self.userManager = userManager
  }
  
  @MainActor func isContact(sessionId: String) -> Bool {
    if let activeUserId = userManager.activeUser?.persistentModelID {
      do {
        var fetchDescriptor = FetchDescriptor<Contact>(predicate: #Predicate { contact in
          contact.recipient.sessionId == sessionId
          && contact.user.persistentModelID == activeUserId
        })
        fetchDescriptor.fetchLimit = 1
        let contacts = try modelContext.fetch(fetchDescriptor)
        return !contacts.isEmpty
      } catch {
        print("Failed to load Contact model")
      }
    }
    return false
  }
  
  @MainActor func addToContacts(sessionId: String, name: String?) {
    if let activeUserId = userManager.activeUser?.persistentModelID {
      do {
        var recipientsFetchDescriptor = FetchDescriptor<Recipient>(predicate: #Predicate { recipient in
          recipient.sessionId == sessionId
        })
        recipientsFetchDescriptor.fetchLimit = 1
        let recipients = try modelContext.fetch(recipientsFetchDescriptor)
        
        let contactRecipient: Recipient
        if(recipients.isEmpty) {
          contactRecipient = Recipient(
            id: UUID(),
            sessionId: sessionId,
            displayName: nil
          )
          modelContext.insert(contactRecipient)
        } else {
          contactRecipient = recipients[0]
        }
        
        let contact = Contact(id: UUID(), recipient: contactRecipient, name: name, user: userManager.activeUser!)
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
        print("Failed to save Contacts model")
      }
    }
  }

  @MainActor func removeFromContacts(sessionId: String) {
    if let activeUserId = userManager.activeUser?.persistentModelID {
      do {
        var fetchDescriptor = FetchDescriptor<Contact>(predicate: #Predicate { contact in
          contact.recipient.sessionId == sessionId
          && contact.user.persistentModelID == activeUserId
        })
        fetchDescriptor.fetchLimit = 1
        let contacts = try modelContext.fetch(fetchDescriptor)
        modelContext.delete(contacts[0])
        try modelContext.save()
      } catch {
        print("Failed to load Contact model")
      }
    }
  }
}
