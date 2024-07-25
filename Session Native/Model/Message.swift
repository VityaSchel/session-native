import Foundation
import SwiftData

@Model
final class Message {
  var id: UUID
  var hash: String
  var timestamp: Date
  var from: Recipient
  var body: String
  @Attribute(.externalStorage) var attachments: [Data]?
  var read: Bool
  
  init(id: UUID, hash: String, timestamp: Date, from: Recipient, body: String, attachments: [Data]? = nil, read: Bool) {
    self.id = id
    self.hash = hash
    self.timestamp = timestamp
    self.from = from
    self.body = body
    self.attachments = attachments
    self.read = read
  }
}
