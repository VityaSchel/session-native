import Foundation
import SwiftUI
import SwiftData

struct ConversationView: View {
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var viewManager: ViewManager
  @EnvironmentObject var userManager: UserManager
  
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
      Messages(
        context: modelContext,
        userManager: userManager,
        conversation: conversation
      )
      .navigationTitle(conversation.recipient.sessionId)
      .background(Color.conversationDefaultBackground)
    } else {
      Text("Conversation not found")
        .foregroundStyle(Color.gray)
    }
  }
}

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

struct Messages: View {
  @Environment(\.modelContext) var modelContext
  var userManager: UserManager
  @StateObject private var viewModel: MessageViewModel
  var conversation: Conversation
  
  init(context: ModelContext, userManager: UserManager, conversation: Conversation) {
    self.userManager = userManager
    self.conversation = conversation
    _viewModel = StateObject(
      wrappedValue: MessageViewModel(
        context: context,
        conversation: conversation
      )
    )
  }
  
  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView(.vertical) {
          LazyVStack {
            Spacer()
              .frame(height: 12)
              .onAppear() {
                if(viewModel.items.count > 10) {
                  viewModel.fetchItems()
                }
              }
            ForEach(viewModel.items) { message in
              ChatMessage(message, viewModel: viewModel)
            }
            Spacer()
              .id("ConversationBottom")
          }
        }
        .padding(.horizontal, 10)
        .onChange(of: viewModel.items, {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 10)) {
              proxy.scrollTo("ConversationBottom")
            }
          }
        })
      }
      .scrollContentBackground(.hidden)
      .defaultScrollAnchor(.bottom)
      .listStyle(.plain)
      .background(Color.conversationDefaultBackground)
      NewMessageInput(
        conversation: conversation,
        messageModel: viewModel
      )
    }
    .alert("Delete message?", isPresented: $viewModel.deleteConfirmation) {
      Button("Delete everywhere", role: .destructive) {
        
      }
      Button("Delete locally", role: .destructive) {
        withAnimation {
          if let deletedMessage = viewModel.deleteConfirmationMessage {
            modelContext.delete(deletedMessage)
          
        }
        viewModel.deleteConfirmationMessage = nil
      }
      Button("Cancel", role: .cancel) {
        viewModel.deleteConfirmation = false
        viewModel.deleteConfirmationMessage = nil
      }
    }
  }
  
  struct ChatMessage: View {
    var message: Message
    var viewModel: MessageViewModel
    
    init(_ message: Message, viewModel: MessageViewModel) {
      self.message = message
      self.viewModel = viewModel
    }
    
    var body: some View {
      MessageBubble(direction: message.from == nil ? .right : .left) {
        Text(message.body)
          .textSelection(.enabled)
          .foregroundStyle(message.from == nil ? Color.black : Color.messageBubbleText)
          .contextMenu(menuItems: {
            MessageContextMenu(message: message)
              .environmentObject(viewModel)
          })
      }
      .contextMenu(menuItems: {
        MessageContextMenu(message: message)
          .environmentObject(viewModel)
      })
    }
    
    struct MessageContextMenu: View {
      var message: Message
      @EnvironmentObject var viewModel: MessageViewModel
      
      var body: some View {
        Button() {
          withAnimation(.easeOut(duration: 0.1)) {
            viewModel.replyTo = message
          }
        } label: {
          Label("􀉌 Reply", systemImage: "arrowshape.turn.up.left")
        }
        Divider()
        Button() {
          NSPasteboard.general.clearContents()
          NSPasteboard.general.setString(message.body, forType: .string)
        } label: {
          Label("􀉁 Copy", systemImage: "doc.on.doc")
        }
        Divider()
        Button() {
          print("Forward")
        } label: {
          Label("􀰞 Forward", systemImage: "arrowshape.turn.up.forward")
        }
        .disabled(true)
        Button() {
          print("Select")
        } label: {
          Label("􀁢 Select", systemImage: "checkmark.circle")
        }
        .disabled(true)
        Divider()
        Button() {
          viewModel.deleteConfirmation = true
          viewModel.deleteConfirmationMessage = message
        } label: {
          Label("􀈑 Delete", systemImage: "trash")
        }
      }
    }
  }
}

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
    VStack(spacing: 0) {
      if let replyTo = messageModel.replyTo {
        HStack {
          VStack(alignment: .leading) {
            Text("Reply to " + getReplyToText(replyTo: replyTo, userManager: userManager))
              .fontWeight(.medium)
              .foregroundStyle(Color.accentColor)
            Text(replyTo.body)
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
          .padding(.vertical, 12)
          .padding(.leading, 16)
          .lineLimit(1...5)
          .onSubmit {
            handleSubmit()
          }
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
    .background(.windowBackground)
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
      hash: "aasnda",
      timestamp: Date(),
      body: body,
      read: false
    )
    
    modelContext.insert(message)
    
    do {
      try modelContext.save()
    } catch {
      print("Failed to save message: \(error)")
    }
    
    messageModel.items.append(message)
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
        let messages = getMessagePreviewMocks(conversation: convos[0])
        for message in messages {
          container.mainContext.insert(message)
        }
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
      .environmentObject(UserManager(container: inMemoryModelContainer))
      .frame(width: 500, height: 300)
  }
}
