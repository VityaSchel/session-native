import Foundation

func getMessagePreviewMocks(conversation: Conversation) -> [Message] {
  var messages: [Message] = []
  for i in 0..<100 {
    messages.append(
      Message(
        id: UUID(),
        conversation: conversation,
        hash: "Hello",
        timestamp: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(103-i)),
        body: String(i),
        read: true
      )
    )
  }
  messages.append(
    Message(
      id: UUID(),
      conversation: conversation,
      hash: "Hello",
      timestamp: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 2),
      from: conversation.recipient,
      body: String("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
      replyTo: messages.last!,
      read: false
    )
  )
  messages.append(
    Message(
      id: UUID(),
      conversation: conversation,
      hash: "Hello",
      timestamp: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 1),
      body: String("Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
      read: false
    )
  )
  return messages
}
