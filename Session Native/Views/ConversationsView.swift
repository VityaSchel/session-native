import SwiftUI
import SwiftData

struct ConversationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        
            Text("Select a conversation")
    }
}

struct ConversationsNav: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Item]
  
  var body: some View {
    List {
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
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}

struct ConversationPreviewItem: View {
  var item: Item
  
  var body: some View {
    NavigationLink {
      Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
    } label: {
      Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
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
    withAnimation {
      let newItem = Item(timestamp: Date())
      modelContext.insert(newItem)
    }
  }
}

#Preview {
    ConversationsView()
        .modelContainer(for: Item.self, inMemory: true)
}
