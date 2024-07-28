import Foundation

func getConversationsPreviewMocks() -> [Conversation] {
  let recipients = getRecipientsPreviewMocks()
  
  let convo1 = Conversation(
    id: UUID(),
    recipient: recipients[1],
    archived: false,
    lastMessage: Message(
      id: UUID(),
      hash: "asjdasdkas",
      timestamp: Date(),
      from: recipients[1],
      body: "Hello hloth",
      read: false
    ),
    typingIndicator: false,
    notifications: Notification(enabled: false)
  )
  
  let convo2 = Conversation(
    id: UUID(),
    recipient: recipients[2],
    archived: false,
    lastMessage: Message(
      id: UUID(),
      hash: "Hello",
      timestamp: Date(),
      from: recipients[0],
      body: "Hi user, welcome to Session Native swift previews glad to see you there",
      read: false
      
    ),
    typingIndicator: false
  )
  
  let convo3 = Conversation(
    id: UUID(),
    recipient: recipients[3],
    archived: false,
    typingIndicator: false
  )
  
  return [convo1, convo2, convo3]
}
