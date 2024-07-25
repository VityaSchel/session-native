import Foundation
import SwiftData

@Model
final class Conversation {
  var id: UUID
  var recipient: Recipient
  var archived: Bool
  var lastMessage: Message?
  var typingIndicator: Bool
  
  init(id: UUID, recipient: Recipient, archived: Bool, lastMessage: Message? = nil, typingIndicator: Bool) {
    self.id = id
    self.recipient = recipient
    self.archived = archived
    if let lastMessageUnwrapped = lastMessage {
      self.lastMessage = lastMessageUnwrapped
    }
    self.typingIndicator = typingIndicator
  }
}
