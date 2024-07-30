import Foundation

func getMessagePreviewMocks(conversation: Conversation) -> [Message] {
  var messages: [Message] = []
  for i in 0..<100 {
    messages.append(
      Message(
        id: UUID(),
        conversation: conversation,
        hash: "Hello",
        timestamp: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(100-i)),
        body: String(i),
        read: false
      )
    )
  }
  return messages
}
