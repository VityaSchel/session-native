import Foundation

func getContactsPreviewMocks(user: User) -> [Contact] {
  let contact1 = Contact(
    id: UUID(),
    recipient: Recipient(
      id: UUID(),
      sessionId: "0512086833b399c18ed903db01df29aa65d00599dc22ac429f82dd57855b543336",
      displayName: "user original name",
      avatar: nil
    ),
    name: "vitya",
    user: user
  )
  let contact2 = Contact(
    id: UUID(),
    recipient: Recipient(
      id: UUID(),
      sessionId: "0512792fc3c47f235aac9c2bfe3cacb3e1e16a4cb3e44f5e0ce96f0517bd92e954",
      displayName: "user display name",
      avatar: nil
    ),
    user: user
  )
  let contact3 = Contact(
    id: UUID(),
    recipient: Recipient(
      id: UUID(),
      sessionId: "05122f02afb2d1caf61fe10cd680ced4af4ac7179bdc7a9345c9a55f3415cb923f",
      displayName: nil,
      avatar: nil
    ),
    user: user
  )
  return [contact1, contact2, contact3]
}
