import SwiftUI
import SwiftData

struct SettingsView: View {
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

struct SettingsNav: View {
  var body: some View {
    List {
      NavigationLink {
        Text("Item 1")
      } label: {
        Text("Item 1")
      }
    }
  }
}

struct SettingsToolbar: ToolbarContent {
  var body: some ToolbarContent {
    ToolbarItem {
      Spacer()
    }
    ToolbarItem {
      Button(action: addItem) {
        Text("Edit")
      }
      .buttonStyle(.link)
    }
  }
  
  private func addItem() {
    
  }
}

#Preview {
    SettingsView()
        .modelContainer(for: Item.self, inMemory: true)
}
