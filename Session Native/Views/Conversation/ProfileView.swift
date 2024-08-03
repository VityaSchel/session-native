import Foundation
import SwiftUI

struct ProfileView: View {
  @Environment (\.modelContext) var modelContext
  @EnvironmentObject var userManager: UserManager
  var conversation: Conversation
  @State var showProfilePopover: Bool = false
  @State var isContact: Bool = false
  
  var body: some View {
    Button {
      showProfilePopover = true
    } label: {
      Avatar(
        avatar: conversation.recipient.avatar,
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
          ProfileButton(icon: isContact ? "person.crop.circle.fill.badge.xmark" : "person.crop.circle.fill.badge.plus", name: isContact ? "Remove contact" : "Add as contact") {
            let contactsManager = ContactsManager(
              context: modelContext,
              userManager: userManager
            )
            if(isContact) {
              contactsManager.removeFromContacts(
                sessionId: conversation.recipient.sessionId
              )
            } else {
              contactsManager.addToContacts(
                sessionId: conversation.recipient.sessionId,
                name: nil
              )
            }
            isContact.toggle()
          }
          .onAppear {
            
          }
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
            .multilineTextAlignment(.center)
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
