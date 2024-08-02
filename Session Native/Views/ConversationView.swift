import Foundation
import SwiftUI
import SwiftData

struct ConversationView: View {
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var viewManager: ViewManager
  @EnvironmentObject var userManager: UserManager
  @State var conversationModel: Conversation?
  @State var showProfilePopover: Bool = false
  
  private func fetchConversation() {
    if let conversationId = viewManager.navigationSelection {
      if let conversationUuid = UUID(uuidString: conversationId) {
        let conversation = try? modelContext.fetch(
          FetchDescriptor(predicate: #Predicate<Conversation> { conversation in
            conversation.id == conversationUuid
          })
        ).first
        conversationModel = conversation
      } else {
        conversationModel = nil
      }
    } else {
      conversationModel = nil
    }
  }
  
  var body: some View {
    Group {
      if let conversation = conversationModel {
        Group {
          Messages(
            context: modelContext,
            userManager: userManager,
            conversation: conversation
          )
          .navigationTitle(conversation.recipient.displayName ?? getSessionIdPlaceholder(sessionId: conversation.recipient.sessionId))
          .background(Color.conversationDefaultBackground)
        }
        .toolbar {
          ToolbarItem(placement: .navigation) {
            Button {
              showProfilePopover = true
            } label: {
              Avatar(
                avatar: conversationModel?.recipient.avatar,
                width: 36,
                height: 36
              )
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showProfilePopover, arrowEdge: .bottom) {
              VStack(alignment: .center) {
                Avatar(
                  avatar: conversation.recipient.avatar,
                  width: 148,
                  height: 148
                )
                Text(conversation.recipient.displayName ?? getSessionIdPlaceholder(sessionId: conversation.recipient.sessionId))
                  .font(.title)
                HStack(spacing: 0) {
                  ProfileButton(icon: "phone.fill", name: "Call")
                  ProfileButton(icon: "person.crop.circle.fill.badge.plus", name: "Add as contact")
                  ProfileButton(icon: conversation.notifications.enabled ? "speaker.slash.fill" : "speaker.wave.2.fill", name: conversation.notifications.enabled ? "Mute" : "Unmute") {
                    conversation.notifications.enabled.toggle()
                    do {
                      try modelContext.save()
                    } catch {
                      print("Failed to save conversation: \(error)")
                    }
                  }
                  ProfileButton(icon: conversation.blocked ? "hand.raised.slash.fill" : "hand.raised.fill", name: conversation.blocked ? "Unblock" : "Block") {
                    conversation.blocked.toggle()
                    do {
                      try modelContext.save()
                    } catch {
                      print("Failed to save conversation: \(error)")
                    }
                  }
                }
                .frame(width: 256)
                .padding(.top, 12)
                VStack(alignment: .leading, spacing: 0) {
                  Text("Session ID")
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                  Divider()
                  HStack {
                    Text(conversation.recipient.sessionId)
                      .font(.system(size: 11, design: .monospaced))
                      .textSelection(.enabled)
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(.horizontal, 10)
                  .padding(.top, 10)
                  .padding(.bottom, 7)
                }
                .background(Color.cardBackground)
                .cornerRadius(8)
              }
              .padding()
              .frame(width: 320)
            }
          }
          ToolbarItem() {
            Button {
              
            } label: {
              Image(systemName: "phone")
            }
          }
        }
      } else {
        Text("Conversation not found")
          .foregroundStyle(Color.gray)
      }
    }
    .onAppear {
      fetchConversation()
    }
    .onChange(of: viewManager.navigationSelection) {
      fetchConversation()
    }
  }
  
  struct ProfileButton: View {
    var icon: String
    var name: String
    var action: () -> Void = {}
    
    var body: some View {
      Button {
        action()
      } label: {
        VStack {
          VStack(spacing: 7) {
            Image(systemName: icon)
              .resizable()
              .scaledToFit()
              .frame(width: 15, height: 15)
              .frame(width: 28, height: 28)
              .background(Color.linkButton)
              .cornerRadius(.infinity)
            Text(name)
              .foregroundStyle(Color.linkButton)
          }
          Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
//      .frame(maxWidth: .infinity)
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
          .padding(.horizontal, 10)
        }
        .onChange(of: conversation) { oldConversation, newConversation in
          if(oldConversation.persistentModelID != newConversation.persistentModelID) {
            viewModel.updateConversation(newConversation)
          }
        }
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
      MessageBubble(
        direction: message.from == nil ? .right : .left,
        timestamp: getFormattedDate(date: message.timestamp),
        status: message.status,
        read: message.read
      ) {
        (Text(message.body)
         /*.textSelection(.enabled)*/ + Text("\u{2066}" +	 String(repeating: "\u{2004}", count: message.from == nil ? 11 : 7) + "\u{2800}"))
          .foregroundStyle(message.from == nil ? Color.black : Color.messageBubbleText)
      }
      .contentShape(Rectangle())
      .contextMenu(menuItems: {
        MessageContextMenu(message: message)
          .environmentObject(viewModel)
      })
      .onTapGesture(count: 2) {
        withAnimation(.easeOut(duration: 0.1)) {
          viewModel.replyTo = message
        }
      }
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

func getFormattedDate(date: Date) -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "HH:mm"
  return dateFormatter.string(from: date)
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
            .padding(.top, 17)
            .padding(.bottom, 16)
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
      hash: "aasnda",
      timestamp: Date(),
      body: body,
      read: false,
      status: .sending
    )
    modelContext.insert(message)
    
    conversation.lastMessage = message
    conversation.updatedAt = Date()
    
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
    var convo = ""
    
    let inMemoryModelContainer: ModelContainer = {
      do {
        let users = getUsersPreviewMocks()
        let convos = getConversationsPreviewMocks(user: users[0])
        convo = convos[0].id.uuidString
        let container = try ModelContainer(for: Schema(storageSchema), configurations: [.init(isStoredInMemoryOnly: true)])
        container.mainContext.insert(convos[0])
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
      .environmentObject(ViewManager(.conversations, convo))
      .environmentObject(UserManager(container: inMemoryModelContainer))
      .frame(width: 500, height: 300)
  }
}
