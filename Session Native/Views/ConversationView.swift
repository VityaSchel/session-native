import Foundation
import SwiftUI
import SwiftData

struct ConversationView: View {
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var viewManager: ViewManager
  private var conversationModel: Conversation? {
    if let conversationId = viewManager.navigationSelection {
      if let conversationUuid = UUID(uuidString: conversationId) {
        return try? modelContext.fetch(
          FetchDescriptor(predicate: #Predicate<Conversation> { conversation in
            conversation.id == conversationUuid
          })
        ).first
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
  
  var body: some View {
    if let conversation = conversationModel {
      Text(conversation.recipient.sessionId)
        .navigationTitle(conversation.recipient.sessionId)
    } else {
      Text("Conversation not found")
    }
  }
}

