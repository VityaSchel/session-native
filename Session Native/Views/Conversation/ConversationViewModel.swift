import Foundation
import SwiftData
import Combine

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
  
  private var cancellables = Set<AnyCancellable>()
  
  init(context: ModelContext, conversation: Conversation) {
    self.dbContext = context
    self.conversation = conversation
    fetchItems()
    
    MessageDeletionNotifier.shared.messageDeleted
      .sink { [weak self] deletedConversation in
        guard let self = self else { return }
        if deletedConversation.id == self.conversation.id {
          self.items.removeAll()
        }
      }
      .store(in: &cancellables)
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
        if let conversation = message.conversation {
          return conversation.persistentModelID == conversationId
        } else {
          return false
        }
      })
      fetchDescriptor.fetchLimit = pageSize
      fetchDescriptor.fetchOffset = currentPage * pageSize
      fetchDescriptor.sortBy = [SortDescriptor(\Message.createdAt, order: .reverse)]
      
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

class MessageDeletionNotifier {
  static let shared = MessageDeletionNotifier()
  
  let messageDeleted = PassthroughSubject<Conversation, Never>()
}
