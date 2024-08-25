import Foundation
import SwiftData

enum MessageStatus: Codable, Equatable {
  case sending
  case sent
  case errored(reason: String)
}

@Model
final class Message {
  var id: UUID
  var conversation: Conversation
  var messageHash: String?
  var createdAt: Date
  var timestamp: Int64?
  var from: Recipient?
  var body: String?
  @Attribute(.externalStorage) var attachments: [Data]?
  var read: Bool
  var status: MessageStatus
  var replyTo: Message?
  var deletedByUser: Bool
  
  init(id: UUID, conversation: Conversation, messageHash: String? = nil, createdAt: Date, from: Recipient? = nil, body: String?, attachments: [Data]? = nil, replyTo: Message? = nil, read: Bool = false, status: MessageStatus = MessageStatus.sent) {
    self.id = id
    self.conversation = conversation
    self.messageHash = messageHash
    self.createdAt = createdAt
    self.timestamp = nil
    self.from = from
    self.body = body
    self.attachments = attachments
    self.read = read
    self.status = status
    self.replyTo = replyTo
    self.deletedByUser = false
  }
}
