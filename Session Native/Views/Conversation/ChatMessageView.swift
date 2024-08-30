import Foundation
import SwiftUI

struct ChatMessage: View {
  var message: Message
  var viewModel: MessageViewModel
  var scrollProxy: ScrollViewProxy
  let messageStatusBarSuffix: String
  
  init(_ message: Message, scrollProxy: ScrollViewProxy, viewModel: MessageViewModel) {
    self.message = message
    self.scrollProxy = scrollProxy
    self.viewModel = viewModel
    self.messageStatusBarSuffix = String(repeating: "\u{2004}", count: message.from == nil ? 10 : 7) + "\u{2800}"
  }
  
  var body: some View {
    MessageBubble(
      message: message,
      scrollProxy: scrollProxy
    ) {
      if message.deletedByUser {
        Text("􀈑 This message was deleted" + self.messageStatusBarSuffix)
          .foregroundStyle(Color.text.opacity(0.5))
      } else if let text = message.body {
        (Text(text)
        + Text("\u{2066}" + self.messageStatusBarSuffix))
        .foregroundStyle(message.from == nil ? Color.black : Color.messageBubbleText)
        .fixedSize(horizontal: false, vertical: true)
      }
    }
    .contentShape(Rectangle())
    .if(!message.deletedByUser) { view in
      view.contextMenu(menuItems: {
        MessageContextMenu(message: message)
          .environmentObject(viewModel)
      })
    }
    .onTapGesture(count: 2) {
      if (message.status == .sent && !message.deletedByUser) {
        withAnimation(.easeOut(duration: 0.1)) {
          viewModel.replyTo = message
        }
      }
    }
    .id(String(message.messageHash ?? ""))
  }
  
  struct MessageContextMenu: View {
    var message: Message
    @EnvironmentObject var viewModel: MessageViewModel
    
    var body: some View {
      Button() {
        if (message.status == .sent) {
          withAnimation(.easeOut(duration: 0.1)) {
            viewModel.replyTo = message
          }
        }
      } label: {
        Label("􀉌 Reply", systemImage: "arrowshape.turn.up.left")
      }
      .disabled(message.status != .sent)
      Divider()
      if let text = message.body {
        Button() {
          NSPasteboard.general.clearContents()
          NSPasteboard.general.setString(text, forType: .string)
        } label: {
          Label("􀉁 Copy", systemImage: "doc.on.doc")
        }
        Divider()
      }
      Button() {
        print("Forward")
      } label: {
        Label("􀰞 Forward", systemImage: "arrowshape.turn.up.forward")
      }
      .disabled(true)
      Button() {
        print("Select")
      } label: {
        Label("􀁢 Select", systemImage: "checkmark.circle")
      }
      .disabled(true)
      if message.from == nil {
        Divider()
        Button() {
          viewModel.deleteConfirmation = true
          viewModel.deleteConfirmationMessage = message
        } label: {
          Label("􀈑 Delete", systemImage: "trash")
        }
      }
    }
  }
}

#Preview {
  ConversationView_Preview.previews
}
