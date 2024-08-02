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
  var notifications: Notification
  @Relationship(
    deleteRule: .cascade,
    inverse: \Message.conversation
  )
  var messages: [Message] = []
  var pinned: Bool = false
  var unreadCount: Int {
    messages.filter { !$0.read }.count
  }
  var hasUnread: Bool {
    unreadCount > 0
  }
  var user: User
  var blocked: Bool = false
  @Relationship(
    deleteRule: .nullify,
    inverse: \Contact.conversation
  )
  var contact: Contact?
  
  init(id: UUID, user: User, recipient: Recipient, archived: Bool, lastMessage: Message? = nil, typingIndicator: Bool, notifications: Notification = Notification(enabled: true), pinned: Bool = false, contact: Contact? = nil) {
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
  }
}

struct Notification: Codable {
  var enabled: Bool
  
  init(enabled: Bool) {
    self.enabled = enabled
  }
}
