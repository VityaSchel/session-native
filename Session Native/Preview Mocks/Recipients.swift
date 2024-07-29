import Foundation

func getRecipientsPreviewMocks() -> [Recipient] {
  let recipient1 = Recipient(
    id: UUID(),
    sessionId: "057aeb66e45660c3bdfb7c62706f6440226af43ec13f3b6f899c1dd4db1b8fce5b",
    displayName: "hloth"
  )
  let recipient2 = Recipient(
    id: UUID(),
    sessionId: "05d871fc80ca007eed9b2f4df72853e2a2d5465a92fcb1889fb5c84aa2833b3b40",
    displayName: "Kee Jefferys"
  )
  let recipient3 = Recipient(
    id: UUID(),
    sessionId: "0512808ee33a5b7135a122f34cb5f45f4025c1b1b0bb231c433c4c94ae99a18862"
  )
  let recipient4 = Recipient(
    id: UUID(),
    sessionId: "0512b000b08e80872aae493d30da55736a37a219c51863ae1075e674ca812af81c"
  )
  return [recipient1, recipient2, recipient3, recipient4]
}
