import Foundation
import SwiftUI

struct MessageBubble<Content>: View where Content: View {
  let direction: ChatBubbleShape.Direction
  let content: () -> Content
  var timestamp: String
  var status: MessageStatus
  var read: Bool
  @State var errorVisible: Bool = false
  @State var errorReason: String = ""
  
  init(direction: ChatBubbleShape.Direction, timestamp: String, status: MessageStatus, read: Bool, @ViewBuilder content: @escaping () -> Content) {
    self.content = content
    self.direction = direction
    self.timestamp = timestamp
    self.status = status
    self.read = read
  }
  
  var body: some View {
    HStack {
      if direction == .right {
        Spacer()
      }
      ZStack {
        content()
          .padding(.vertical, 6)
          .padding(direction == .left ? .leading : .trailing, 11)
          .padding(direction == .left ? .trailing : .leading, 8)
          .background(direction == .left ? Color.messageBubble : Color.accentColor)
          .clipShape(ChatBubbleShape(direction: direction))
          .overlay(
            GeometryReader { geometry in
              Text(timestamp)
                .font(.system(size: 11))
                .italic()
                .padding(5)
                .cornerRadius(5)
                .foregroundStyle(direction == .left ? Color.gray : Color.black.opacity(0.8))
                .position(x: geometry.size.width - (direction == .left ? 25 : 43), y: geometry.size.height - 13)
              if(direction == .right) {
                Group {
                  switch(status) {
                  case .sending:
                    Spinner(style: .light, size: 8)
                  case .sent:
                    if read {
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
                .position(x: geometry.size.width - 17, y: geometry.size.height - 13)
              }
            }, alignment: .bottomTrailing
          )
      }
      if direction == .left {
        Spacer()
      }
    }
//    .padding([(direction == .left) ? .leading : .trailing, .top, .bottom], 20)
//      .padding((direction == .right) ? .leading : .trailing, 50)
  }
}

let roundness: CGFloat = 0.65

struct ChatBubbleShape: Shape {
  enum Direction {
    case left
    case right
  }
  
  let direction: Direction
  
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

#Preview {
  VStack {
    MessageBubble(direction: .left, timestamp: "12:00", status: .sent, read: false) {
      Text("Hello, World!\u{2066}" + String(repeating: "\u{2004}", count: false ? 11 : 7) + "\u{2800}")
        .foregroundStyle(Color.white)
    }
    MessageBubble(direction: .right, timestamp: "12:00", status: .sent, read: true) {
      Text("Hello, World!\u{2066}" + String(repeating: "\u{2004}", count: true ? 11 : 7) + "\u{2800}")
        .foregroundStyle(Color.black)
    }
    MessageBubble(direction: .right, timestamp: "12:00", status: .sent, read: false) {
      Text("Hello, World!\u{2066}" + String(repeating: "\u{2004}", count: true ? 11 : 7) + "\u{2800}")
        .foregroundStyle(Color.black)
    }
    MessageBubble(direction: .right, timestamp: "00:00", status: .errored(reason: "Preview error"), read: false) {
      Text("Hello, World!\u{2066}" + String(repeating: "\u{2004}", count: true ? 11 : 7) + "\u{2800}")
        .foregroundStyle(Color.black)
    }
    MessageBubble(direction: .right, timestamp: "00:00", status: .sending, read: false) {
      Text("Hello, World!\u{2066}" + String(repeating: "\u{2004}", count: true ? 11 : 7) + "\u{2800}")
        .foregroundStyle(Color.black)
    }
  }
  .background(Color.conversationDefaultBackground)
}
