import SwiftUI
import SwiftData

struct ConversationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Conversation]

    var body: some View {
        Text("Select a conversation")
    }
}

struct ConversationsNav: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Conversation]
  
  var body: some View {
    List {
      Section {
        ForEach(items) { conversation in
          ConversationPreviewItem(item: conversation)
            .swipeActions(edge: .leading) {
              Button {
                print("Read conversation")
              } label: {
                Label("Read", systemImage: "message.badge.filled.fill")
              }
              .tint(.blue)
            }
            .swipeActions(edge: .trailing) {
              Button {
                print("Muting conversation")
              } label: {
                Label("Mute", systemImage: "bell.slash.fill")
              }
              .tint(.indigo)
              
              
              Button {
                print("Move to archive")
              } label: {
                Label("Move to archive", systemImage: "archivebox.fill")
              }
              
              Button(role: .destructive) {
                print("Deleting conversation")
              } label: {
                Label("Delete", systemImage: "trash.fill")
              }
            }
        }
        .onDelete(perform: deleteItems)
      }
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}

struct ConversationPreviewItem: View {
  var item: Conversation
  
  var body: some View {
    NavigationLink {
      
    } label: {
      Avatar(avatar: item.recipient.avatar)
      VStack(alignment: .leading) {
        Text(item.recipient.displayName ?? getSessionIdPlaceholder(sessionId: item.recipient.sessionId))
          .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
        if let lastMessage = item.lastMessage {
          Text(lastMessage.body)
            .lineLimit(2)
        }
      }
    }
  }
}

struct ConversationsToolbar: ToolbarContent {
  @Environment(\.modelContext) private var modelContext
  
  var body: some ToolbarContent {
    ToolbarItem {
      Spacer()
    }
    ToolbarItem {
      Button(action: addItem) {
        Label("New conversation", systemImage: "square.and.pencil")
      }
    }
  }
  
  private func addItem() {
    modelContext.insert(
      Conversation(
        id: UUID(),
        recipient: Recipient(
          id: UUID(),
          sessionId: "057aeb66e45660c3bdfb7c62706f6440226af43ec13f3b6f899c1dd4db1b8fce5b",
          displayName: "hloth"
        ),
        archived: false,
        lastMessage: Message(
          id: UUID(),
          hash: "asjdasdkas",
          timestamp: Date(),
          from: Recipient(
            id: UUID(),
            sessionId: "05123d0edc7681aab3c6ab0895853cde71ee13536028de01ba3caa9522a1edbd19",
            displayName: "biba"
          ),
          body: "Hello worldnnbbnbnnbnbnbHello worldnnbbnbnnbnbnbHello worldnnbbnbnnbnbnbHello worldnnbbnbnnbnbnbHello worldnnbbnbnnbnbnbHello worldnnbbnbnnbnbnbHello worldnnbbnbnnbnbnbHello worldnnbbnbnnbnbnbHello worldnnbbnbnnbnbnbHello worldnnbbnbnnbnbnb",
          read: false
          
        ),
        typingIndicator: false
      )
    )
  }
}

#Preview {
    ConversationsView()
        .modelContainer(for: Conversation.self, inMemory: true)
}
