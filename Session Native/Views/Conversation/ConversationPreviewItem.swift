import Foundation
import SwiftUI
import SwiftData

struct ConversationPreviewItem: View {
  var conversation: Conversation
  @EnvironmentObject var userManager: UserManager
  @EnvironmentObject var viewManager: ViewManager
  @State var selected: Bool = false
  var onClear: () -> Void
  var onDelete: () -> Void
  
  var body: some View {
    if !conversation.isDeleted {
      Button {
        viewManager.setActiveNavigationSelection(conversation.id.uuidString)
      } label: {
        HStack {
          Avatar(avatar: conversation.recipient.avatar)
          VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 4) {
              Text(conversation.contact?.name ?? conversation.recipient.displayName ?? getSessionIdPlaceholder(sessionId: conversation.recipient.sessionId))
                .fontWeight(.bold)
                .foregroundStyle(selected ? Color.black.opacity(0.8) : Color.text)
              if !conversation.notifications.enabled {
                Image(systemName: "speaker.slash.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(height: 12)
                  .foregroundStyle(selected ? Color.black : Color.text)
                  .opacity(0.45)
              }
            }
            if conversation.typingIndicator {
              HStack(alignment: .center, spacing: 2) {
                Text("typing")
                  .foregroundStyle(selected ? Color.black.opacity(0.6) : Color.gray)
                TypingIndicatorView(style: selected ? .light : .dark, size: 4)
                  .padding(.top, 8)
              }
            } else if let lastMessage = conversation.lastMessage {
              if lastMessage.from == nil {
                if selected {
                  (Text("You: ")
                    .foregroundStyle(Color.black.opacity(0.3))
                   + (lastMessage.deletedByUser
                      ? Text("Deleted message")
                    .foregroundStyle(Color.black.opacity(0.3))
                      : Text(lastMessage.body ?? "")
                    .foregroundStyle(Color.black.opacity(0.6))
                     )
                  )
                  .lineLimit(2)
                } else {
                  (Text("You: ")
                    .foregroundStyle(.opacity(0.4))
                   + (lastMessage.deletedByUser
                      ? Text("Deleted message")
                    .foregroundStyle(.opacity(0.4))
                      : Text(lastMessage.body ?? "")
                    .foregroundStyle(.opacity(0.6))
                     )
                  )
                  .lineLimit(2)
                }
              } else {
                Text(lastMessage.body ?? "")
                  .foregroundStyle(selected ? Color.black.opacity(0.6) : Color.text.opacity(0.6))
                  .lineLimit(2)
                  .fixedSize(horizontal: false, vertical: true)
              }
            } else {
              Text("Empty chat")
                .foregroundStyle(selected ? Color.black.opacity(0.3) : Color.text.opacity(0.4))
            }
          }
          Spacer()
          VStack(alignment: .trailing) {
            HStack(spacing: 2) {
              if let lastMessage = conversation.lastMessage,
                 lastMessage.from == nil {
                switch(lastMessage.status) {
                case .sending:
                  Spinner(style: selected ? .light : .dark, size: 8)
                    .padding(.trailing, 4)
                case .sent:
                  Checkmark(style: selected ? .light : .dark, double: lastMessage.read, size: 20)
                case .errored:
                  ZStack {
                    Circle()
                      .foregroundStyle(Color.white)
                      .frame(width: 12, height: 12)
                    Image(systemName: "exclamationmark.circle.fill")
                      .foregroundColor(Color(hex: "#f95252"))
                  }
                }
              }
              Text(shortConversationUpdatedAt(conversation.updatedAt))
                .foregroundStyle(selected ? Color.black.opacity(0.3) : Color.text.opacity(0.4))
            }
            Spacer()
            HStack {
              if conversation.unreadMessages > 0 {
                Group {
                  Text(
                    conversation.unreadMessages > 99
                    ? "99+"
                    : String(conversation.unreadMessages)
                  )
                  .font(.system(size: 10))
                  .foregroundStyle(Color.white)
                }
                .frame(width: conversation.unreadMessages > 99 ? 24 : 20, height: 20)
                .background(conversation.notifications.enabled ? Color.linkButton : Color.gray)
                .cornerRadius(.infinity)
              }
              if conversation.pinned {
                Image(systemName: "pin.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 12, height: 12)
                  .rotationEffect(.degrees(45))
                  .foregroundStyle(selected ? Color.black.opacity(0.3) : Color.text.opacity(0.4))
              }
            }
          }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 6)
      }
      .buttonStyle(.plain)
      .onChange(of: viewManager.navigationSelection) {
        selected = viewManager.navigationSelection == conversation.id.uuidString
      }
      .if(selected) { view in
        view.listRowBackground(Color.accentColorConstant)
      }
      .swipeActions(edge: .leading) {
        Button {
          conversation.messages!.forEach({ message in
            message.read = true
          })
        } label: {
          Label("", systemImage: "message.badge.filled.fill")
        }
        .tint(.blue)
      }
      .swipeActions(edge: .trailing) {
        Button {
          conversation.notifications.enabled = !conversation.notifications.enabled
        } label: {
          if conversation.notifications.enabled {
            Label("", systemImage: "bell.slash.fill")
          } else {
            Label("", systemImage: "bell.fill")
          }
        }
        .tint(.indigo)
        .accessibility(label: Text(conversation.notifications.enabled ? "Mute conversation" : "Unmute conversation"))
        Button(role: .destructive) {
          onDelete()
        } label: {
          Label("", systemImage: "trash.fill")
        }
        .accessibility(label: Text("Delete conversation"))
        Button {
          withAnimation {
            conversation.archived.toggle()
          }
        } label: {
          Label("", systemImage: conversation.archived ? "square.and.arrow.up.fill" : "archivebox.fill")
        }
        .accessibility(label: Text(conversation.archived ? "Unarchive conversation" : "Archive conversation"))
      }
      .contextMenu(ContextMenu(menuItems: {
        if(conversation.pinned) {
          Button("􀎨 Unpin") {
            conversation.pinned = false
          }
        } else {
          Button("􀎦 Pin") {
            conversation.pinned = true
          }
        }
        if(conversation.notifications.enabled) {
          Button("􀋝 Mute") {
            // TODO: notifications
            conversation.notifications.enabled = false
          }
        } else {
          Button("􀋙 Unmute") {
            conversation.notifications.enabled = true
          }
        }
        Button("􀌤 Mark as read") {
          conversation.unreadMessages = 0
          let unreadMessages = conversation.messages!.filter({ msg in
            msg.from != nil && msg.read == false && msg.timestamp != nil
          })
          let privacySettings_showReadCheckmarks = UserDefaults.standard.optionalBool(forKey: "sendReadCheckmarks_" + conversation.id.uuidString)
          ?? UserDefaults.standard.optionalBool(forKey: "sendReadCheckmarksByDefault")
          ?? true
          if privacySettings_showReadCheckmarks {
            request([
              "type": "mark_as_read",
              "conversation": .string(conversation.recipient.sessionId),
              "messagesTimestamps": .array(unreadMessages.map({ msg in
                  .int(msg.timestamp!)
              }))
            ])
          }
          unreadMessages.forEach({ msg in
            msg.read = true
          })
        }
        Divider()
        if(conversation.archived) {
          Button("􀈂 Unarchive") {
            conversation.archived = false
          }
        } else {
          Button("􀈭 Archive") {
            conversation.archived = true
          }
        }
        Divider()
        Button("􀁠 Clear history") {
          onClear()
        }
        Button {
          onDelete()
        } label: {
          Label("􀈑 Delete conversation", systemImage: "trash")
            .foregroundStyle(Color.red)
        }
      }))
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
