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
      VStack {
        Messages(context: modelContext, conversation: conversation)
      }
        .navigationTitle(conversation.recipient.sessionId)
    } else {
      Text("Conversation not found")
        .foregroundStyle(Color.gray)
    }
  }
}

//class MessageViewModel: ObservableObject {
//  @Published var items: [Message] = []
//  @Published var isLoading = false
//  private var currentPage = 0
//  private let pageSize = 20
//  
//  private var dbContext: ModelContext
//  private var conversation: Conversation
//  
//  init(context: ModelContext, conversation: Conversation) {
//    self.dbContext = context
//    self.conversation = conversation
//    fetchItems()
//  }
//  
//  func fetchItems() {
//    guard !isLoading else { return }
//    isLoading = true
//    
//    do {
//      var fetchDescriptor = FetchDescriptor(predicate: #Predicate<Message> { message in
////        message.conversationId == conversation.id
//        true
//      })
//      fetchDescriptor.fetchLimit = pageSize
//      fetchDescriptor.fetchOffset = currentPage * pageSize
//      fetchDescriptor.sortBy = [SortDescriptor(\Message.timestamp, order: .forward)]
//      
//      let fetchedItems = try dbContext.fetch(fetchDescriptor)
//      
//      DispatchQueue.main.async {
//        self.items.append(contentsOf: fetchedItems)
//        self.isLoading = false
//        self.currentPage += 1
//      }
//    } catch {
//      print("Failed to fetch items: \(error)")
//      self.isLoading = false
//    }
//  }
//}

struct Messages: View {
  @Environment(\.modelContext) var modelContext
//  @StateObject private var viewModel: MessageViewModel
  
  init(context: ModelContext, conversation: Conversation) {
//    _viewModel = StateObject(
//      wrappedValue: MessageViewModel(
//        context: context,
//        conversation: conversation
//      )
//    )
  }
  
  var body: some View {
//    MessageBubble(direction: .left) {
//      Text("I'd like to add you as my recovery contact. If you accept, you'll be able to help me recover my data and regain access to my account. I will call or contact you in person when I need help.")
////        .foregroundStyle(Color.)
//    }
    Text("123")
  }
}

struct ConversationView_Preview: PreviewProvider {
  static var previews: some View {
    let convos = getConversationsPreviewMocks()
    
    let inMemoryModelContainer: ModelContainer = {
      do {
        let container = try ModelContainer(for: Schema(storageSchema), configurations: [.init(isStoredInMemoryOnly: true)])
        container.mainContext.insert(convos[0])
        let users = getUsersPreviewMocks()
        container.mainContext.insert(users[0])
        try container.mainContext.save()
        UserDefaults.standard.set(users[0].id.uuidString, forKey: "activeUser")
        return container
      } catch {
        fatalError("Could not create ModelContainer: \(error)")
      }
    }()
    
    ConversationView()
      .modelContainer(inMemoryModelContainer)
      .environmentObject(ViewManager(.conversations, convos[0].id.uuidString))
      .frame(width: 500, height: 300)
  }
}
