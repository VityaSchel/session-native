import Foundation
import SwiftData

@Model
final class Contact {
  var id: UUID
  var recipient: Recipient
  var name: String?
  
  init(id: UUID, recipient: Recipient, name: String? = nil) {
    self.id = id
    self.recipient = recipient
    if let nameUnwrapped = name {
      self.name = nameUnwrapped
    }
  }
}
