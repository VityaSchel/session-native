import SwiftUI
import SwiftData

struct ContactsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]

    var body: some View {
        Text("Select a conversation")
    }

    private func addItem() {
        
    }

    private func deleteItems(offsets: IndexSet) {
        
    }
}

struct ContactsNav: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Contact]
  @State private var searchText = ""
  
  var body: some View {
    SearchField(searchText: $searchText)
    Divider()
    List {
      Section {
        ForEach(items) { item in
          NavigationLink {
            
          } label: {
            Avatar(avatar: item.recipient.avatar)
            VStack {
              Text(item.name ?? item.recipient.displayName ?? getSessionIdPlaceholder(sessionId: item.recipient.sessionId))
              
            }
            Text("Item")
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

struct ContactsToolbar: ToolbarContent {
  @Environment(\.modelContext) private var modelContext
  
  var body: some ToolbarContent {
    ToolbarItem {
      Spacer()
    }
    ToolbarItem {
      Button(action: addItem) {
        Label("Add contact", systemImage: "person.badge.plus")
      }
    }
  }
  
  private func addItem() {
    print("Adding contact")
  }
}

#Preview {
    ContactsView()
        .modelContainer(for: Contact.self, inMemory: true)
}
