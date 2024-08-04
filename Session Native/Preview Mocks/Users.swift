import Foundation

func getUsersPreviewMocks() -> [User] {
  let user1 = User(
    id: UUID(),
    sessionId: "057aeb66e45660c3bdfb7c62706f6440226af43ec13f3b6f899c1dd4db1b8fce5b",
    displayName: "hloth"
  )
  let user2 = User(
    id: UUID(),
    sessionId: "05123c7bf529754d0540db25a78e69c73c45b614a6e7a7b8b47004db7452ae616f",
    displayName: "one time session user throwaway I used to test some bots etc"
  )
  let user3 = User(
    id: UUID(),
    sessionId: "05123acfd235ce2513eb20cb5bd6695dd4de365dd91e4914e3054edefe558bd251"
  )
  return [user1, user2, user3]
}
