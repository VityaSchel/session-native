import Foundation
import SwiftData
import MessagePack
import SwiftUI

class EventHandler: ObservableObject {
  @Published var modelContext: ModelContext
  
  private var isSubscribed = false
  
  private var newMessageHandler: (([MessagePackValue : MessagePackValue]) -> Void)?
  private var messageDeletedHandler: (([MessagePackValue : MessagePackValue]) -> Void)?
  private var typingIndicatorHandler: (([MessagePackValue : MessagePackValue]) -> Void)?
  private var messageReadHandler: (([MessagePackValue : MessagePackValue]) -> Void)?
  
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }
  
  func subscribeToEvents() {
    if !isSubscribed {
      newMessageHandler = { [weak self] message in
        self?.handleNewMessage(message)
      }
      messageDeletedHandler = { [weak self] message in
        self?.handleMessageDeleted(message)
      }
      typingIndicatorHandler = { [weak self] message in
        self?.handleTypingIndicator(message)
      }
      messageReadHandler = { [weak self] message in
        self?.handleMessageRead(message)
      }
      
      backendApiClient.on(event: "new_message", handler: newMessageHandler!)
      backendApiClient.on(event: "message_deleted", handler: messageDeletedHandler!)
      backendApiClient.on(event: "typing_indicator", handler: typingIndicatorHandler!)
      backendApiClient.on(event: "message_read", handler: messageReadHandler!)
      
      isSubscribed = true
    }
  }
  
  func unsubscribeFromEvents() {
    if isSubscribed {
      if let newMessageHandler = newMessageHandler {
        backendApiClient.off(event: "new_message", handler: newMessageHandler)
      }
      if let messageDeletedHandler = messageDeletedHandler {
        backendApiClient.off(event: "message_deleted", handler: messageDeletedHandler)
      }
      if let typingIndicatorHandler = typingIndicatorHandler {
        backendApiClient.off(event: "typing_indicator", handler: typingIndicatorHandler)
      }
      if let messageReadHandler = messageReadHandler {
        backendApiClient.off(event: "message_read", handler: messageReadHandler)
      }
      
      isSubscribed = false
    }
  }
  
  private func handleNewMessage(_ message: [MessagePackValue : MessagePackValue]) {
    DispatchQueue.main.async {
      print("New message: \(message)")
//      message["message"]
    }
  }
  
  private func handleMessageDeleted(_ message: [MessagePackValue : MessagePackValue]) {
    DispatchQueue.main.async {
      print("Message deleted: \(message)")
    }
  }
  
  private func handleTypingIndicator(_ message: [MessagePackValue : MessagePackValue]) {
    DispatchQueue.main.async {
      print("Typing indicator: \(message)")
      if let indicator = message["indicator"]?.dictionaryValue,
         let sessionId = indicator["conversation"]?.stringValue,
         let isTyping = indicator["isTyping"]?.boolValue {
        do {
          if let conversation = try self.modelContext.fetch(FetchDescriptor<Conversation>(predicate: #Predicate { conversation in
            conversation.recipient.sessionId == sessionId
          })).first {
            conversation.typingIndicator = isTyping
            try self.modelContext.save()
          }
        } catch {
          print("Failed to update typing indicator.")
        }
      }
    }
  }
  
  private func handleMessageRead(_ message: [MessagePackValue : MessagePackValue]) {
    DispatchQueue.main.async {
      print("Message read: \(message)")
    }
  }
}
