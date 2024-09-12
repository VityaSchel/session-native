import Foundation
import SwiftUI

struct DeveloperSettingsView: View {
  @Environment (\.modelContext) var modelContext
  
  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading) {
        Button() {
          clearAllLocalData()
        } label: {
          HStack {
            Text("Clear all local data")
              .foregroundStyle(Color.red)
            Spacer()
          }
          .padding(.all, 10)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color.cardBackground)
        .cornerRadius(8)
        Text("Immediately deletes local database, preferences and keychain items")
          .foregroundStyle(Color.red)
          .font(.system(size: 10))
          .foregroundStyle(Color.gray.opacity(0.75))
          .padding(.top, 1)
          .padding(.bottom, 8)
          .padding(.horizontal, 16)
        Button() {
          addStresstestData()
        } label: {
          HStack {
            Text("Add big data streestest")
            Spacer()
          }
          .padding(.all, 10)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color.cardBackground)
        .cornerRadius(8)
        Text("Immediately adds 10 accounts, 100 random contacts to each, 1000 chats to each with 100 000-1 000 000 random messages to each")
          .font(.system(size: 10))
          .foregroundStyle(Color.gray.opacity(0.75))
          .padding(.top, 1)
          .padding(.bottom, 8)
          .padding(.horizontal, 16)
      }
      .frame(width: 400)
    }
    .padding()
  }
  
  private func clearAllLocalData() {
    print("Clearing all local data")
  }
  
  private func addStresstestData() {
    print("Adding big data streestest")
    
    let user = User(id: UUID(), sessionId: randomSessionId())
    user.displayName = "John Doe"
    
    modelContext.insert(user)
    
    for i in 1...100 {
      let recipient = Recipient(
        id: UUID(),
        sessionId: randomSessionId(),
        displayName: "Contact \(i)"
      )
      modelContext.insert(recipient)
      let chat = Conversation(
        id: UUID(),
        user: user,
        recipient: recipient,
        archived: false,
        typingIndicator: false
      )
      modelContext.insert(chat)
      for j in 1...(i == 100 ? 100000 : Int.random(in: 1..<100)) {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        let message = Message(
          id: UUID(),
          conversation: chat,
          createdAt: Date(),
          body: "Message \(j)\n\(String((0..<64).map { _ in letters.randomElement()! }))"
        )
        modelContext.insert(message)
      }
    }
    
    do {
      try modelContext.save()
      print("Finished adding stress data")
    } catch {
      print("Error saving stresstest data: \(error)")
    }
  }
}

private func randomSessionId() -> String {
  let letters = "0123456789abcdef"
  return "05" + String((0..<64).map { _ in letters.randomElement()! })
}

#Preview {
  SettingsView_Preview.previewWithTab("debug")
}
