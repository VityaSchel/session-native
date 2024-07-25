import SwiftData

let storageSchema: [any PersistentModel.Type] = [
  Conversation.self,
  Message.self,
  Recipient.self,
  Contact.self,
  User.self
]
