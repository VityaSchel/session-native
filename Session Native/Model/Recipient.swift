import Foundation
import SwiftData

@Model
final class Recipient {
  var id: UUID
  var sessionId: String
  var displayName: String?
  @Attribute(.externalStorage) var avatar: Data?
  var _profileKey: String
  
  init(id: UUID, sessionId: String, displayName: String? = nil, avatar: Data? = nil) {
    self.id = id
    self.sessionId = sessionId
    self.displayName = displayName
    self.avatar = avatar
    self._profileKey = ""
  }
}
