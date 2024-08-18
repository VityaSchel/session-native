import Foundation

func getConversationsPreviewMocks(user: User) -> [Conversation] {
  let recipients = getRecipientsPreviewMocks()
  
  let convo1 = Conversation(
    id: UUID(uuidString: "aaf2f108-7ca0-46e8-85f6-88e5f4f16132")!,
    user: user,
    recipient: recipients[1],
    archived: false,
    lastMessage: nil,
    typingIndicator: false,
    notifications: Notification(enabled: false)
  )
  convo1.lastMessage = Message(
    id: UUID(),
    conversation: convo1,
    messageHash: "asjdasdkas",
    createdAt: Date(),
    from: recipients[1],
    body: "Hello hloth",
    read: false
  )
  convo1.unreadMessages += 1
  
  let convo2 = Conversation(
    id: UUID(uuidString: "6e92da23-7f3c-4c0f-bb9c-73477b35983b")!,
    user: user,
    recipient: recipients[2],
    archived: false,
    lastMessage: nil,
    typingIndicator: false
  )
  convo2.lastMessage = Message(
    id: UUID(),
    conversation: convo2,
    messageHash: "Hello",
    createdAt: Date(),
    body: "Hi user, welcome to Session Native swift previews glad to see you there",
    read: false
  )
  convo2.updatedAt = Date().addingTimeInterval(-60*60*24*3)
  
  let convo3 = Conversation(
    id: UUID(),
    user: user,
    recipient: recipients[3],
    archived: false,
    typingIndicator: false,
    pinned: true
  )
  convo3.updatedAt = Date().addingTimeInterval(-60*60*24*30)
  
  return [convo1, convo2, convo3]
}
