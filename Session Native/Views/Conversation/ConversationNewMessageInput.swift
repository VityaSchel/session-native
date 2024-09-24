import Foundation
import SwiftUI
import MessagePack
import UniformTypeIdentifiers

struct NewMessageInput: View {
  @EnvironmentObject var keyMonitor: GlobalKeyMonitor
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
        ScrollView([.horizontal]) {
          HStack {
            ForEach(messageModel.attachments) { attachment in
              AttachmentPreviewSend(
                attachment: attachment,
                onRemove: {
                  withAnimation {
                    messageModel.attachments.removeAll(where: { $0.id == attachment.id })
                  }
                }
              )
            }
          }
          .padding(.all, messageModel.attachments.count > 0 ? 8 : 0)
        }
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
          Button(
            action: {
              openFileSelector()
            },
            label: {
              Image(systemName: "paperclip")
                .foregroundColor(.accentColor)
            }
          )
          .buttonStyle(.plain)
          TextField("Message...", text: $messageText, axis: .vertical)
            .textFieldStyle(.plain)
            .padding(.top, 17)
            .padding(.bottom, 16)
            .padding(.leading, 8)
            .lineLimit(1...5)
            .onSubmit {
              handleSubmit()
            }
            .onAppear {
              keyMonitor.onFilePasted = { pastedData, pastedName, pastedMimeType in
                self.handlePasteFile(pastedData, pastedName, pastedMimeType)
              }
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
        .padding(.leading, 16)
      }
      .border(width: 1, edges: [.top], color: Color.separator)
      .background(.windowBackground)
    }
  }
  
  private func handlePasteFile(_ data: Data, _ name: String, _ type: String) {
    if(data.count > kMaxFileSize) {
      messageModel.attachmentTooBigAlert = true
      return
    }
    withAnimation {
      messageModel.attachments.append(
        Attachment(
          id: UUID(),
          name: name,
          size: Int(data.count),
          mimeType: type,
          data: data
        )
      )
    }
  }
  
  private func openFileSelector() {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    openPanel.allowsMultipleSelection = true
    
    if openPanel.runModal() == .OK {
      openPanel.urls.forEach { url in
        loadFileData(from: url)
      }
    }
  }
  
  private func loadFileData(from url: URL) {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let data = try Data(contentsOf: url)
        DispatchQueue.main.async {
          let fileExtension = url.pathExtension
          let type = UTType(filenameExtension: fileExtension)
          if data.count > kMaxFileSize {
            messageModel.attachmentTooBigAlert = true
            return
          }
          withAnimation {
            messageModel.attachments.append(
              Attachment(
                id: UUID(),
                name: url.lastPathComponent,
                size: Int(data.count),
                mimeType: type?.preferredMIMEType ?? "text/plain",
                data: data
              )
            )
          }
        }
      } catch {
        print("Error loading image data: \(error)")
      }
    }
  }
  
  private func handleSubmit() {
    guard !messageText.isEmpty else {
      return
    }
    
    let body = messageText
    let attachments = messageModel.attachments
    messageText = ""
    messageModel.attachments = []
    let attachmentsPreviews = attachments.map({ attachment in
      let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
      let attachmentName = UUID().uuidString
      let attachmentTempFileURL = tempDirectory.appendingPathComponent(attachmentName)
      try! attachment.data.write(to: attachmentTempFileURL)
      
      return AttachmentPreview(
        id: UUID(),
        name: attachment.name,
        size: attachment.data.count,
        mimeType: attachment.mimeType,
        contentURL: attachmentTempFileURL
      )
    })
    let message = Message(
      id: UUID(),
      conversation: conversation,
      createdAt: Date(),
      body: body,
      attachments: attachmentsPreviews,
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
      "attachments": .array(attachments.map { attachment in
        .map([
          "name": .string(attachment.name),
          "type": .string(attachment.mimeType),
          "size": .int(Int64(attachment.size)),
          "data": .binary(attachment.data)
        ])
      }),
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
