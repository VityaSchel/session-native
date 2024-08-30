import Foundation
import SwiftUI

struct MessageBubble<Content>: View where Content: View {
  @EnvironmentObject var userManager: UserManager
  var message: Message
  var scrollProxy: ScrollViewProxy
  let content: () -> Content
  var direction: ChatBubbleShapeDirection {
    message.from == nil ? .right : .left
  }
  @State var width: CGFloat = 100
  
  init(message: Message, scrollProxy: ScrollViewProxy, @ViewBuilder content: @escaping () -> Content) {
    self.message = message
    self.content = content
    self.scrollProxy = scrollProxy
  }
  
  var body: some View {
    HStack {
      if direction == .right {
        Spacer()
      }
      VStack(alignment: .leading) {
        if let reply = message.replyTo {
          Button {
            if let replyReferenceHash = reply.messageHash {
              withAnimation {
                scrollProxy.scrollTo(replyReferenceHash)
              }
            }
          } label: {
            HStack(spacing: 0) {
              Rectangle()
                .background(Color.white)
                .frame(width: 2)
              VStack(alignment: .leading) {
                Text(
                  reply.from != nil
                  ? (
                    reply.from!.displayName ??
                    getSessionIdPlaceholder(sessionId: reply.from!.sessionId)
                  ) : (
                    userManager.activeUser?.displayName ?? getSessionIdPlaceholder(sessionId: userManager.activeUser!.sessionId)
                  )
                )
                .fontWeight(.medium)
                Text(
                  reply.body ?? ""
                )
              }
              .padding(.horizontal, 5)
              .padding(.vertical, 2)
            }
            .frame(width: width, height: 40, alignment: .leading)
            .background(message.from == nil ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
            .foregroundStyle(message.from == nil ? Color.black : Color.messageBubbleText)
            .cornerRadius(3.0)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
        content()
          .overlay(
            GeometryReader { geometry in
              MessageStatusBar(message: message)
                .onAppear {
                  width = geometry.size.width
                }
            },
            alignment: .bottomTrailing
          )
      }
      .padding(.vertical, 6)
      .padding(direction == .left ? .leading : .trailing, 11)
      .padding(direction == .left ? .trailing : .leading, 8)
      .background(direction == .left ? Color.messageBubble : Color.accentColorConstant)
      .clipShape(ChatBubbleShape(direction: direction))
      if direction == .left {
        Spacer()
      }
    }
//    .padding([(direction == .left) ? .leading : .trailing, .top, .bottom], 20)
//      .padding((direction == .right) ? .leading : .trailing, 50)
  }
}

let roundness: CGFloat = 0.65

enum ChatBubbleShapeDirection {
  case left
  case right
}

struct ChatBubbleShape: Shape {
  let direction: ChatBubbleShapeDirection
  
  func path(in rect: CGRect) -> Path {
    return (direction == .left) ? getLeftBubblePath(in: rect) : getRightBubblePath(in: rect)
  }
  
  private func getLeftBubblePath(in rect: CGRect) -> Path {
    let width = rect.width
    let height = rect.height
    let path = Path { p in
      p.move(to: CGPoint(x: roundness*25, y: height))
      p.addLine(to: CGPoint(x: width - roundness*20, y: height))
      p.addCurve(to: CGPoint(x: width, y: height - roundness*20),
                 control1: CGPoint(x: width - roundness*8, y: height),
                 control2: CGPoint(x: width, y: height - roundness*8))
      p.addLine(to: CGPoint(x: width, y: roundness*20))
      p.addCurve(to: CGPoint(x: width - roundness*20, y: 0),
                 control1: CGPoint(x: width, y: roundness*8),
                 control2: CGPoint(x: width - roundness*8, y: 0))
      p.addLine(to: CGPoint(x: roundness*21, y: 0))
      p.addCurve(to: CGPoint(x: roundness*4, y: roundness*20),
                 control1: CGPoint(x: roundness*12, y: 0),
                 control2: CGPoint(x: roundness*4, y: roundness*8))
      p.addLine(to: CGPoint(x: roundness*4, y: height - roundness*11))
      p.addCurve(to: CGPoint(x: 0, y: height),
                 control1: CGPoint(x: roundness*4, y: height - roundness*1),
                 control2: CGPoint(x: 0, y: height))
      p.addLine(to: CGPoint(x: -roundness*0.05, y: height - roundness*0.01))
      p.addCurve(to: CGPoint(x: roundness*11.0, y: height - roundness*4.0),
                 control1: CGPoint(x: roundness*4.0, y: height + roundness*0.5),
                 control2: CGPoint(x: roundness*8, y: height - roundness*1))
      p.addCurve(to: CGPoint(x: roundness*25, y: height),
                 control1: CGPoint(x: roundness*16, y: height),
                 control2: CGPoint(x: roundness*20, y: height))
      
    }
    return path
  }
  
  private func getRightBubblePath(in rect: CGRect) -> Path {
    let width = rect.width
    let height = rect.height
    let path = Path { p in
      p.move(to: CGPoint(x: roundness*25, y: height))
      p.addLine(to: CGPoint(x:  roundness*20, y: height))
      p.addCurve(to: CGPoint(x: 0, y: height - roundness*20),
                 control1: CGPoint(x: roundness*8, y: height),
                 control2: CGPoint(x: 0, y: height - roundness*8))
      p.addLine(to: CGPoint(x: 0, y: roundness*20))
      p.addCurve(to: CGPoint(x: roundness*20, y: 0),
                 control1: CGPoint(x: 0, y: roundness*8),
                 control2: CGPoint(x: roundness*8, y: 0))
      p.addLine(to: CGPoint(x: width - roundness*21, y: 0))
      p.addCurve(to: CGPoint(x: width - roundness*4, y: roundness*20),
                 control1: CGPoint(x: width - roundness*12, y: 0),
                 control2: CGPoint(x: width - roundness*4, y: roundness*8))
      p.addLine(to: CGPoint(x: width - roundness*4, y: height - roundness*11))
      p.addCurve(to: CGPoint(x: width, y: height),
                 control1: CGPoint(x: width - roundness*4, y: height - 1),
                 control2: CGPoint(x: width, y: height))
      p.addLine(to: CGPoint(x: width + roundness*0.05, y: height - roundness*0.01))
      p.addCurve(to: CGPoint(x: width - roundness*11, y: height - roundness*4),
                 control1: CGPoint(x: width - roundness*4, y: height + roundness*0.5),
                 control2: CGPoint(x: width - roundness*8, y: height - roundness*1))
      p.addCurve(to: CGPoint(x: width - roundness*25, y: height),
                 control1: CGPoint(x: width - roundness*16, y: height),
                 control2: CGPoint(x: width - roundness*20, y: height))
      
    }
    return path
  }
}

struct MessageStatusBar: View {
  var message: Message
  var direction: ChatBubbleShapeDirection {
    message.from == nil ? .right : .left
  }
  @State var errorVisible: Bool = false
  @State var errorReason: String = ""
  
  var body: some View {
    GeometryReader { geometry in
      Text(getFormattedDate(date: message.createdAt))
        .font(.system(size: 11))
        .italic()
        .padding(5)
        .cornerRadius(5)
        .foregroundStyle(direction == .left ? Color.gray : Color.black.opacity(0.8))
        .position(x: geometry.size.width - (direction == .left ? 18 : 32), y: geometry.size.height - 7)
      if(direction == .right) {
        Group {
          switch(message.status) {
          case .sending:
            Spinner(style: .light, size: 8)
          case .sent:
            if message.read {
              Checkmark(style: .light, double: true, size: 16, thickness: 1)
                .offset(x: -1)
            } else {
              Checkmark(style: .light, size: 16, thickness: 1)
            }
          case .errored(let reason):
            Button() {
              errorVisible = true
              errorReason = reason
            } label: {
              ZStack {
                Circle()
                  .foregroundStyle(Color.white)
                  .frame(width: 12, height: 12)
                Image(systemName: "exclamationmark.circle.fill")
                  .foregroundColor(Color(hex: "#f95252"))
              }
            }
            .buttonStyle(.plain)
            .alert(isPresented: $errorVisible) {
              Alert(title: Text("Error sending message"), message: Text(errorReason), dismissButton: .cancel())
            }
          }
        }
        .position(x: geometry.size.width - 6, y: geometry.size.height - 7)
      }
    }
  }
}

#Preview {
  ConversationView_Preview.previews
}
