import Foundation
import SwiftUI
import SwiftData

let buttonSize: CGFloat = 24.0

struct AppViewsNavigation: View {
  @Environment (\.modelContext) var modelContext
  @EnvironmentObject var appViewManager: ViewManager
  @EnvironmentObject var userManager: UserManager
  
  var body: some View {
    HStack(spacing: 0) {
      NavButton(view: .contacts, icon: "person.crop.circle.fill")
        .layoutPriority(1)
      NavButton(view: .conversations, icon: "bubble.left.and.bubble.right.fill")
        .layoutPriority(1)
        .contextMenu(ContextMenu(menuItems: {
          Button("Read all") {
            do {
              if let activeUserId = userManager.activeUser?.persistentModelID {
                try modelContext.fetch(
                  FetchDescriptor(predicate: #Predicate<Conversation> {
                    $0.user.persistentModelID == activeUserId
                  })
                ).forEach({ conversation in
                  conversation.unreadMessages = 0
                  conversation.messages!.forEach({ message in
                    message.read = true
                  })
                })
              }
            } catch {
              print("Error reading all messages: \(error)")
            }
          }
        }))
      NavButton(view: .settings, icon: "gear")
        .layoutPriority(1)
    }
    .padding(.vertical, 12.5)
    .border(width: 1, edges: [.top], color: Color("Separator"))
    .background(.ultraThinMaterial)
  }
  
  private struct NavButton: View {
    @EnvironmentObject var appViewManager: ViewManager
    var view: AppView
    var icon: String
    
    var body: some View {
      Button(action: {
        appViewManager.setActiveView(view)
      }) {
        Image(systemName: icon)
          .resizable()
          .frame(width: buttonSize, height: buttonSize)
          .frame(maxWidth: .infinity)
          .contentShape(Rectangle())
      }
      .foregroundColor(appViewManager.appView == view ? Color.accentColor : Color.gray)
      .buttonStyle(PlainButtonStyle())
    }
  }
}

#Preview {
  AppViewsNavigation()
    .environmentObject(ViewManager())
}
