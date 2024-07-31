import Foundation
import SwiftData

@Model
final class User {
  var id: UUID
  var sessionId: String
  var displayName: String?
  @Attribute(.externalStorage) var avatar: Data?
  @Relationship(
    deleteRule: .cascade,
    inverse: \Conversation.user
  )
  var conversations: [Conversation] = []
  
  init(id: UUID, sessionId: String, displayName: String? = nil, avatar: Data? = nil) {
    self.id = id
    self.sessionId = sessionId
    self.displayName = displayName
    self.avatar = avatar
  }
}
