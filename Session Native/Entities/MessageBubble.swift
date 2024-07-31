import Foundation
import SwiftUI

struct MessageBubble<Content>: View where Content: View {
  let direction: ChatBubbleShape.Direction
  let content: () -> Content
  init(direction: ChatBubbleShape.Direction, @ViewBuilder content: @escaping () -> Content) {
    self.content = content
    self.direction = direction
  }
  
  var body: some View {
    HStack {
      if direction == .right {
        Spacer()
      }
      content()
        .padding(.vertical, 6)
        .padding(direction == .left ? .leading : .trailing, 11)
        .padding(direction == .left ? .trailing : .leading, 8)
        .background(direction == .left ? Color.messageBubble : Color.accentColor)
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
  HStack {
    MessageBubble(direction: .left) {
      Text("Hello, World!")
        .foregroundStyle(Color.white)
    }
  }
  .background(Color.conversationDefaultBackground)
}
