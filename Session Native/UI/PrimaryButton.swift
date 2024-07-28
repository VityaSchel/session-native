import Foundation
import SwiftUI

struct PrimaryButton: View {
  var text: String
  var action: () -> Void
  var width: CGFloat = 200
  
  init(_ text: String, width: CGFloat = 200, action: @escaping () -> Void) {
    self.text = text
    self.action = action
    self.width = width
  }
  
  var body: some View {
    Button(action: action) {
      Text(text)
        .frame(width: self.width - 16, alignment: .center)
      .fontWeight(.medium)
    }
    .buttonStyle(.borderedProminent)
    .tint(.accent)
    .controlSize(.extraLarge)
  }
}

#Preview {
  HStack {
    PrimaryButton("Hello, world!", action: {})
  }
  .frame(width: 300)
  .padding(20)
}
