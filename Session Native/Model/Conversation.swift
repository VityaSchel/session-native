import Foundation
import SwiftData

@Model
final class Conversation {
  var id: UUID
  var recipient: Recipient
  var archived: Bool
  var lastMessage: Message?
  var updatedAt: Date
  var typingIndicator: Bool
  var notifications: AppNotification
  @Relationship(
    deleteRule: .nullify,
    inverse: \Message.conversation
  )
  var messages: [Message]? = []
  var pinned: Bool = false
  var user: User
  var blocked: Bool = false
  @Relationship(
    deleteRule: .nullify,
    inverse: \Contact.conversation
  )
  var contact: Contact?
  var unreadMessages: Int
  var showTypingIndicator: Bool?
  var sendReadReceipts: Bool?
  
  init(id: UUID, user: User, recipient: Recipient, archived: Bool, lastMessage: Message? = nil, typingIndicator: Bool, notifications: AppNotification = AppNotification(enabled: true), pinned: Bool = false, contact: Contact? = nil) {
    self.id = id
    self.user = user
    self.recipient = recipient
    self.archived = archived
    if let lastMessageUnwrapped = lastMessage {
      self.lastMessage = lastMessageUnwrapped
    }
    self.typingIndicator = typingIndicator
    self.notifications = notifications
    self.pinned = pinned
    self.updatedAt = Date()
    self.blocked = false
    self.contact = contact
    self.unreadMessages = 0
    self.showTypingIndicator = nil
    self.sendReadReceipts = nil
  }
}

struct AppNotification: Codable {
  var enabled: Bool
  
  init(enabled: Bool) {
    self.enabled = enabled
  }
}
