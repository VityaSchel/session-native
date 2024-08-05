import Foundation
import SwiftData

enum MessageStatus: Codable {
  case sending
  case sent
  case errored(reason: String)
}

@Model
final class Message {
  var id: UUID
  var conversation: Conversation
  var hash: String?
  var timestamp: Date
  var from: Recipient?
  var body: String
  @Attribute(.externalStorage) var attachments: [Data]?
  var read: Bool
  var status: MessageStatus
  var replyTo: Message?
  
  init(id: UUID, conversation: Conversation, hash: String? = nil, timestamp: Date, from: Recipient? = nil, body: String, attachments: [Data]? = nil, replyTo: Message? = nil, read: Bool = false, status: MessageStatus = MessageStatus.sent) {
    self.id = id
    self.conversation = conversation
    self.hash = hash
    self.timestamp = timestamp
    self.from = from
    self.body = body
    self.attachments = attachments
    self.read = read
    self.status = status
    self.replyTo = replyTo
  }
}
