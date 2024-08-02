import Foundation
import SwiftData

@Model
final class Contact {
  var id: UUID
  var recipient: Recipient
  var name: String?
  var user: User
  var addedAt: Date
  var conversation: Conversation?
  
  init(id: UUID, recipient: Recipient, name: String? = nil, user: User) {
    self.id = id
    self.recipient = recipient
    self.name = name
    self.user = user
    self.addedAt = Date()
  }
}
