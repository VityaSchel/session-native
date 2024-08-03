import Foundation
import SwiftData

class MessageViewModel: ObservableObject {
  @Published var items: [Message] = []
  @Published var isLoading = false
  @Published var replyTo: Message?
  @Published var deleteConfirmation: Bool = false
  @Published var deleteConfirmationMessage: Message?
  
  private var currentPage = 0
  private let pageSize = 20
  
  private var dbContext: ModelContext
  private var conversation: Conversation
  
  init(context: ModelContext, conversation: Conversation) {
    self.dbContext = context
    self.conversation = conversation
    fetchItems()
  }
  
  func updateConversation(_ newConversation: Conversation) {
    self.conversation = newConversation
    self.items.removeAll()
    self.currentPage = 0
    fetchItems()
  }
  
  func fetchItems() {
    guard !isLoading else { return }
    isLoading = true
    
    do {
      let conversationId = conversation.persistentModelID
      var fetchDescriptor = FetchDescriptor(predicate: #Predicate<Message> { message in
        message.conversation.persistentModelID == conversationId
      })
      fetchDescriptor.fetchLimit = pageSize
      fetchDescriptor.fetchOffset = currentPage * pageSize
      fetchDescriptor.sortBy = [SortDescriptor(\Message.timestamp, order: .reverse)]
      
      let fetchedItems = try dbContext.fetch(fetchDescriptor).reversed()
      
      DispatchQueue.main.async {
        self.items.insert(contentsOf: fetchedItems, at: 0)
        self.isLoading = false
        self.currentPage += 1
      }
    } catch {
      print("Failed to fetch items: \(error)")
      self.isLoading = false
    }
  }
}
