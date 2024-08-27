import Foundation
import SwiftUI
import SwiftData

struct ProfileView: View {
  @Environment (\.modelContext) var modelContext
  @EnvironmentObject var userManager: UserManager
  var conversation: Conversation
  @Binding var showProfilePopover: Bool
  @State var isContact: Bool = false
  @State var showTypingIndicator = true
  @State var sendReadCheckmarks = true
  @State var name: String = ""
  @State var editingContactName: Bool = false
  
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
        HStack {
          if editingContactName {
            TextField("Contact name", text: $name)
              .onSubmit {
                if conversation.contact != nil {
                  conversation.contact!.name = name.isEmpty ? nil : name
                  editingContactName = false
                }
              }
              .frame(width: 256)
          } else {
            Text(conversation.contact?.name ?? conversation.recipient.displayName ?? getSessionIdPlaceholder(sessionId: conversation.recipient.sessionId))
              .font(.title)
          }
          if isContact && !editingContactName {
            Button {
              editingContactName = true
            } label: {
              Image(systemName: "pencil")
                .padding(.all, 6)
                .background(Color.text.opacity(0.2))
                .contentShape(Circle())
                .cornerRadius(.infinity)
            }
            .buttonStyle(.plain)
          }
        }
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
              .fixedSize(horizontal: false, vertical: true)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 10)
          .padding(.top, 10)
          .padding(.bottom, 7)
        }
        .background(Color.cardBackground)
        .cornerRadius(8)
        VStack(spacing: 0) {
          Button {
            withAnimation {
              showTypingIndicator.toggle()
            }
          } label: {
            Toggle(isOn: $showTypingIndicator.animation()) {
              HStack(alignment: .center, spacing: 0) {
                Text("Display typing indicator (")
                TypingIndicatorView(staticView: true, size: 4)
                Text(") to recipient")
                Spacer()
              }
            }
            .toggleStyle(.switch)
            .padding(.all, 10)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          Divider()
            .padding(.horizontal, 10)
          Button {
            withAnimation {
              sendReadCheckmarks.toggle()
            }
          } label: {
            Toggle(isOn: $sendReadCheckmarks.animation()) {
              HStack(spacing: 0) {
                Text("Show read checkmarks (")
                Checkmark(style: .dark, double: true, size: 16)
                  .padding(.trailing, 2)
                Text(") to recipient")
                Spacer()
              }
            }
            .toggleStyle(.switch)
            .padding(.all, 10)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
        .background(Color.cardBackground)
        .cornerRadius(8)
      }
      .padding()
      .frame(width: 350)
      .onChange(of: showTypingIndicator) {
        conversation.showTypingIndicator = showTypingIndicator
      }
      .onAppear {
        isContact = conversation.contact != nil
        if let contactName = conversation.contact?.name {
          name = contactName
        } else {
          name = conversation.recipient.displayName ?? ""
        }
      }
    }
    .onAppear {
      if let sendTypingIndicatorForConvo = UserDefaults.standard.optionalBool(forKey: "showTypingIndicators_" + conversation.id.uuidString) {
        showTypingIndicator = sendTypingIndicatorForConvo
      } else {
        showTypingIndicator = UserDefaults.standard.optionalBool(forKey: "showTypingIndicatorsByDefault") ?? true
      }
      if let showReadCheckmarksForConvo = UserDefaults.standard.optionalBool(forKey: "sendReadCheckmarks_" + conversation.id.uuidString) {
        sendReadCheckmarks = showReadCheckmarksForConvo
      } else {
        sendReadCheckmarks = UserDefaults.standard.optionalBool(forKey: "sendReadCheckmarksByDefault") ?? true
      }
    }
    .onChange(of: sendReadCheckmarks) {
      UserDefaults.standard.set(sendReadCheckmarks, forKey: "sendReadCheckmarks_" + conversation.id.uuidString)
    }
    .onChange(of: showTypingIndicator) {
      UserDefaults.standard.set(showTypingIndicator, forKey: "showTypingIndicators_" + conversation.id.uuidString)
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
            .foregroundColor(.white)
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
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    var conversations: [Conversation] = []
    
    let inMemoryModelContainer: ModelContainer = {
      do {
        let container = try ModelContainer(for: Schema(storageSchema), configurations: [.init(isStoredInMemoryOnly: true)])
        let users = getUsersPreviewMocks()
        conversations = getConversationsPreviewMocks(user: users[0])
        container.mainContext.insert(users[0])
        container.mainContext.insert(conversations[0])
        try! container.mainContext.save()
        return container
      } catch {
        fatalError("Could not create ModelContainer: \(error)")
      }
    }()
    
    return ProfileView(
      conversation: conversations[0],
      showProfilePopover: .constant(true)
    )
      .modelContainer(inMemoryModelContainer)
      .environmentObject(UserManager(container: inMemoryModelContainer))
      .frame(width: 48, height: 48)
      .previewLayout(.sizeThatFits)
  }
}
