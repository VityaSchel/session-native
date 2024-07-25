import SwiftUI
import SwiftData

struct ContactsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        Text("Select a conversation")
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
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

struct ContactsNav: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Item]
  
  var body: some View {
    List {
      ForEach(items) { item in
        NavigationLink {
          Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
        } label: {
          Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
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

struct ContactsToolbar: ToolbarContent {
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
        .modelContainer(for: Item.self, inMemory: true)
}
