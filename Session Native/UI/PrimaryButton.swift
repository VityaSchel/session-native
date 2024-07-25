import Foundation
import SwiftUI

struct PrimaryButton: View {
  var text: String
  var action: () -> Void
  
  init(_ text: String, action: @escaping () -> Void) {
    self.text = text
    self.action = action
  }
  
  var body: some View {
    Button(action: action) {
      Text(text)
      .frame(width: 200, alignment: .center)
      .fontWeight(.medium)
    }
    .buttonStyle(.borderedProminent)
    .tint(.accent)
    .controlSize(.extraLarge)
    .frame(width: 200)
  }
}

#Preview {
  HStack {
    PrimaryButton("Hello, world!", action: {})
  }
  .padding(20)
}
