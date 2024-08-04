import Foundation
import SwiftUI
import SwiftData

struct ConversationView: View {
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var viewManager: ViewManager
  @EnvironmentObject var userManager: UserManager
  @State var conversationModel: Conversation?
  
  private func fetchConversation() {
    if let conversationId = viewManager.navigationSelection {
      if let conversationUuid = UUID(uuidString: conversationId) {
        let conversation = try? modelContext.fetch(
          FetchDescriptor(predicate: #Predicate<Conversation> { conversation in
            conversation.id == conversationUuid
          })
        ).first
        conversationModel = conversation
        conversationModel?.unreadMessages = 0
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
            ProfileView(conversation: conversation)
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
}

struct Messages: View {
  @Environment(\.modelContext) var modelContext
  var userManager: UserManager
  var conversation: Conversation
  @StateObject private var viewModel: MessageViewModel
  
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
}

func getFormattedDate(date: Date) -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "HH:mm"
  return dateFormatter.string(from: date)
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
