import Foundation
import SwiftData

@Model
final class Conversation {
  var id: UUID
  var recipient: Recipient
  var archived: Bool
  var lastMessage: Message?
  var typingIndicator: Bool
  var notifications: Notification
  @Relationship(
    deleteRule: .cascade,
    inverse: \Message.conversation
  )
  var messages: [Message] = []
  
  init(id: UUID, recipient: Recipient, archived: Bool, lastMessage: Message? = nil, typingIndicator: Bool, notifications: Notification = Notification(enabled: true)) {
    self.id = id
    self.recipient = recipient
    self.archived = archived
    if let lastMessageUnwrapped = lastMessage {
      self.lastMessage = lastMessageUnwrapped
    }
    self.typingIndicator = typingIndicator
    self.notifications = notifications
  }
}

@Model
final class Notification {
  var enabled: Bool
  
  init(enabled: Bool) {
    self.enabled = enabled
  }
}
