import SwiftUI
import SwiftData
import Combine

struct ConversationsView: View {
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject private var viewManager: ViewManager
  @EnvironmentObject private var userManager: UserManager

  var body: some View {
    switch(viewManager.navigationSelection) {
    case "new":
      NewConversationView()
    case nil:
      TipsView()
    default:
      ConversationView()
    }
  }
}

struct ConversationPreviewItem: View {
  var item: Conversation
  @EnvironmentObject var userManager: UserManager
  @EnvironmentObject var viewManager: ViewManager
  @State var selected: Bool = false
  
  var body: some View {
    Button {
      viewManager.setActiveNavigationSelection(item.id.uuidString)
    } label: {
      HStack {
        Avatar(avatar: item.recipient.avatar)
        VStack(alignment: .leading) {
          HStack(alignment: .center, spacing: 4) {
            Text(item.contact?.name ?? item.recipient.displayName ?? getSessionIdPlaceholder(sessionId: item.recipient.sessionId))
              .fontWeight(.bold)
              .foregroundStyle(selected ? Color.black.opacity(0.8) : Color.white)
            if !item.notifications.enabled {
              Image(systemName: "speaker.slash.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 12)
                .padding(.top, 4)
                .foregroundStyle(selected ? Color.black : Color.white)
                .opacity(0.45)
            }
          }
          if let lastMessage = item.lastMessage {
            if lastMessage.from == nil {
              if selected {
                (Text("You: ")
                  .foregroundStyle(Color.black.opacity(0.3))
                 + Text(lastMessage.body)
                  .foregroundStyle(Color.black.opacity(0.6))
                )
                .lineLimit(2)
              } else {
                (Text("You: ")
                  .foregroundStyle(.opacity(0.4))
                 + Text(lastMessage.body)
                  .foregroundStyle(.opacity(0.6))
                )
                .lineLimit(2)
              }
            } else {
              Text(lastMessage.body)
                .foregroundStyle(selected ? Color.black.opacity(0.6) : Color.white.opacity(0.6))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            }
          } else {
            Text("Empty chat")
              .foregroundStyle(selected ? Color.black.opacity(0.3) : Color.white.opacity(0.4))
          }
        }
        Spacer()
        VStack(alignment: .trailing) {
          Text(shortConversationUpdatedAt(item.updatedAt))
            .foregroundStyle(selected ? Color.black.opacity(0.3) : Color.white.opacity(0.4))
          Spacer()
          if item.pinned {
            Image(systemName: "pin.fill")
              .resizable()
              .scaledToFit()
              .frame(width: 12, height: 12)
              .rotationEffect(.degrees(45))
              .foregroundStyle(selected ? Color.black.opacity(0.3) : Color.white.opacity(0.4))
          }
        }
      }
      .contentShape(Rectangle())
      .padding(.vertical, 6)
    }
    .buttonStyle(.plain)
    .onChange(of: viewManager.navigationSelection) {
      selected = viewManager.navigationSelection == item.id.uuidString
    }
    .if(selected) { view in
      view.listRowBackground(Color.accentColor)
    }
  }
  
  private func shortConversationUpdatedAt(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    
    if calendar.isDateInYesterday(date) || calendar.isDateInToday(date) {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm"
      return formatter.string(from: date)
    }
    
    if let daysAgo = calendar.date(byAdding: .day, value: -6, to: now),
       date >= daysAgo {
      let formatter = DateFormatter()
      formatter.dateFormat = "EE"
      let dayString = formatter.string(from: date)
      return String(dayString.prefix(2))
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "d.MM.yy"
    return formatter.string(from: date)
  }
}

struct ConversationsView_Preview: PreviewProvider {
  static var previews: some View {
    let inMemoryModelContainer: ModelContainer = {
      do {
        let container = try ModelContainer(for: Schema(storageSchema), configurations: [.init(isStoredInMemoryOnly: true)])
        let users = getUsersPreviewMocks()
        container.mainContext.insert(users[0])
        let convos = getConversationsPreviewMocks(user: users[0])
        container.mainContext.insert(convos[0])
        container.mainContext.insert(convos[1])
        container.mainContext.insert(convos[2])
        try container.mainContext.save()
        UserDefaults.standard.set(users[0].id.uuidString, forKey: "activeUser")
        return container
      } catch {
        fatalError("Could not create ModelContainer: \(error)")
      }
    }()
    
    let userManager = UserManager(container: inMemoryModelContainer)
    
    return Group {
      NavigationSplitView {
        VStack {
          ConversationsNav(userManager: userManager)
          AppViewsNavigation()
        }
        .toolbar {
          ConversationsToolbar()
        }
        .frame(minWidth: 200)
        .toolbar(removing: .sidebarToggle)
      } detail: {
        ConversationsView()
      }
    }
    .modelContainer(inMemoryModelContainer)
    .environmentObject(userManager)
    .environmentObject(ViewManager(.conversations))
  }
}
