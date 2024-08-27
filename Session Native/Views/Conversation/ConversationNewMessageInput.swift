import Foundation
import SwiftUI
import MessagePack

struct NewMessageInput: View {
  @State private var messageText = ""
  var conversation: Conversation
  @EnvironmentObject var userManager: UserManager
  @Environment (\.modelContext) var modelContext
  @ObservedObject var messageModel: MessageViewModel
  
  @MainActor
  func getReplyToText(replyTo: Message, userManager: UserManager) -> String {
    if let from = replyTo.from {
      return from.displayName ?? getSessionIdPlaceholder(sessionId: from.sessionId)
    } else {
      return userManager.activeUser?.displayName ?? getSessionIdPlaceholder(sessionId: userManager.activeUser?.sessionId ?? "")
    }
  }
  
  var body: some View {
    if conversation.blocked {
      Button {
        conversation.blocked = false
        do {
          try modelContext.save()
        } catch {
          print("Failed to save conversation: \(error)")
        }
      } label: {
        Label("Unblock", systemImage: "hand.raised.slash.fill")
          .frame(height: 48)
          .frame(maxWidth: .infinity)
          .background(.windowBackground)
          .foregroundColor(Color.linkButton)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .border(width: 1, edges: [.top], color: Color.separator)
    } else {
      VStack(spacing: 0) {
        if let replyTo = messageModel.replyTo {
          HStack {
            VStack(alignment: .leading) {
              Text("Reply to " + getReplyToText(replyTo: replyTo, userManager: userManager))
                .fontWeight(.medium)
                .foregroundStyle(Color.accentColor)
              Text(replyTo.body ?? "Empty message")
            }
            .padding(.leading, 10)
            .border(width: 2, edges: [.leading], color: Color.accentColor)
            .cornerRadius(3.0)
            Spacer()
            Button(action: {
              withAnimation(.easeOut(duration: 0.1)) {
                messageModel.replyTo = nil
              }
            }) {
              Image(systemName: "xmark.circle")
                .resizable()
                .frame(width: 18, height: 18)
            }
            .buttonStyle(.plain)
          }
          .padding(.horizontal, 12)
          .padding(.top, 6)
        }
        HStack {
          TextField("Message...", text: $messageText, axis: .vertical)
            .textFieldStyle(.plain)
            .padding(.top, 17)
            .padding(.bottom, 16)
            .padding(.leading, 16)
            .lineLimit(1...5)
            .onSubmit {
              handleSubmit()
            }
            .onChange(of: messageText, {
              let privacySettings_sendTypingIndicator = UserDefaults.standard.optionalBool(forKey: "showTypingIndicators_" + conversation.id.uuidString)
                ?? UserDefaults.standard.optionalBool(forKey: "showTypingIndicatorsByDefault")
                ?? true
              if(privacySettings_sendTypingIndicator) {
                request([
                  "type": "set_typing_indicator",
                  "recipient": .string(conversation.recipient.sessionId),
                  "show": .bool(messageText.isEmpty == false)
                ])
              }
            })
          Button(
            action: {
              handleSubmit()
            },
            label: {
              Image(systemName: "paperplane.fill")
                .foregroundColor(.accentColor)
            }
          )
          .buttonStyle(.plain)
        }
        .padding(.trailing, 12)
      }
      .border(width: 1, edges: [.top], color: Color.separator)
      .background(.windowBackground)
    }
  }
  
  private func handleSubmit() {
    guard !messageText.isEmpty else {
      return
    }
    
    let body = messageText
    messageText = ""
    let message = Message(
      id: UUID(),
      conversation: conversation,
      createdAt: Date(),
      body: body,
      replyTo: messageModel.replyTo,
      read: false,
      status: .sending
    )
    messageModel.replyTo = nil
    modelContext.insert(message)
    
    conversation.lastMessage = message
    conversation.updatedAt = Date()
    
    do {
      try modelContext.save()
    } catch {
      print("Failed to save message: \(error)")
    }
    
    messageModel.addNewMessage(message)
    
    var messageRequest: [MessagePackValue: MessagePackValue] = [
      "type": "send_message",
      "body": .string(body),
      "recipient": .string(conversation.recipient.sessionId),
    ]
    if let replyTo = message.replyTo {
      messageRequest["replyTo"] = .map([
        "author": .string(replyTo.from != nil ? replyTo.from!.sessionId : userManager.activeUser!.sessionId),
        "timestamp": .int(replyTo.timestamp!),
        "text": .string(replyTo.from?.sessionId ?? "")
      ])
    }
    request(MessagePackValue.map(messageRequest)) { response in
      if response["ok"]?.boolValue == false {
        DispatchQueue.main.async {
          message.status = MessageStatus.errored(reason: response["error"]?.stringValue ?? "Unknown error")
        }
      } else {
        if let hash = response["hash"]?.stringValue,
           let timestamp = response["timestamp"]?.intValue {
          DispatchQueue.main.async {
            message.messageHash = hash
            message.timestamp = Int64(timestamp)
            message.status = .sent
          }
        }
      }
    }
  }
}
