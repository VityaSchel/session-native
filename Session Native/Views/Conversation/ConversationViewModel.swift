import Foundation
import SwiftData
import Combine

struct Attachment: Identifiable {
  var id: UUID
  var name: String
  var size: Int
  var mimeType: String
  var data: Data
}

@Model
final class AttachmentPreview: ObservableObject {
  var id: UUID
  var name: String
  var size: Int
  var mimeType: String
  var contentURL: URL?
  var downloading: Bool
  
  init(id: UUID, name: String, size: Int, mimeType: String, contentURL: URL? = nil, downloading: Bool = false) {
    self.id = id
    self.name = name
    self.size = size
    self.mimeType = mimeType
    self.contentURL = contentURL
    self.downloading = downloading
  }
}

class MessageViewModel: ObservableObject {
  @Published var items: [Message] = []
  @Published var isLoading = false
  @Published var replyTo: Message?
  @Published var attachments: [Attachment] = []
  @Published var deleteConfirmation: Bool = false
  @Published var deleteConfirmationMessage: Message?
  
  private var currentPage = 0
  private let pageSize = 20
  private var offset = 0
  
  private var dbContext: ModelContext
  private var conversation: Conversation
  
  private var cancellables = Set<AnyCancellable>()
  
  init(context: ModelContext, conversation: Conversation) {
    self.dbContext = context
    self.conversation = conversation
    fetchItems()
    
    MessageViewModelNotifier.shared.messageDeleted
      .sink { [weak self] deletedConversation in
        guard let self = self else { return }
        if deletedConversation.id == self.conversation.id {
          self.items.removeAll()
        }
      }
      .store(in: &cancellables)
    
    MessageViewModelNotifier.shared.newMessageReceived
      .sink { [weak self] newMessage in
        guard let self = self else { return }
        self.addNewMessage(newMessage)
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
      fetchDescriptor.fetchOffset = currentPage * pageSize + offset
      fetchDescriptor.sortBy = [SortDescriptor(\Message.createdAt, order: .reverse)]
      
      let fetchedItems = try dbContext.fetch(fetchDescriptor).reversed()
      
      DispatchQueue.main.async {
        let newItems = fetchedItems.filter { newItem in
          !self.items.contains(where: { $0.id == newItem.id })
        }
        self.items.insert(contentsOf: newItems, at: 0)
        self.isLoading = false
        self.currentPage += 1
      }
    } catch {
      print("Failed to fetch items: \(error)")
      self.isLoading = false
    }
  }
  
  func addNewMessage(_ message: Message) {
    items.append(message)
    offset += 1
  }
}

class MessageViewModelNotifier {
  static let shared = MessageViewModelNotifier()
  
  let messageDeleted = PassthroughSubject<Conversation, Never>()
  let newMessageReceived = PassthroughSubject<Message, Never>()
}
