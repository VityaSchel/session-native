import Foundation
import SwiftUI

let tips = [
  "You can switch between multiple Sessions in 􀍟",
  "Swipe conversation to the left and click 􀈮 to archive it",
  "Add contacts via 􀉮 to change their display name locally",
  "Click 􀊫 to show search bar in contacts or conversations tab"
]

struct TipsView: View {
  var body: some View {
    VStack(spacing: 12) {
      Text("Tip")
        .font(.system(.title2, weight: .bold))
      VStack {
        Text(tips[Int.random(in: 1..<tips.count)])
          .padding(.all, 18)
          .multilineTextAlignment(.center)
      }
      .border(width: 1, edges: [Edge.leading, Edge.bottom, Edge.trailing, Edge.top], color: Color.secondary)
      //.cornerRadius(24)
    }
    .padding(.all, 24)
  }
}

#Preview {
  TipsView()
}
