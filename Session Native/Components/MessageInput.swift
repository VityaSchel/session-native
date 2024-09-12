import SwiftUI
import AppKit

import SwiftUI
import AppKit

// Custom NSTextView subclass
class CustomTextView: NSTextView {
  var onNewline: (() -> Void)?
  
  override func keyDown(with event: NSEvent) {
    if event.modifierFlags.contains(.shift) && event.keyCode == 36 {
      // Shift + Enter pressed
      onNewline?()
      return
    } else if event.modifierFlags.contains(.option) && event.keyCode == 36 {
      // Option + Enter pressed
      onNewline?()
      return
    }
    super.keyDown(with: event)
  }
}

struct CustomTextViewRepresentable: NSViewRepresentable {
  @Binding var text: String
  var onNewline: (() -> Void)?
  
  func makeNSView(context: Context) -> CustomTextView {
    let textView = CustomTextView()
    textView.isRichText = false
    textView.autoresizingMask = [.width, .height]
    textView.onNewline = {
      // Insert newline and update binding
      let currentText = textView.string
      let selectedRange = textView.selectedRange()
      let newText = currentText as NSString
      let newTextWithNewline = newText.replacingCharacters(in: selectedRange, with: "\n")
      text = newTextWithNewline
      textView.string = newTextWithNewline
      textView.setSelectedRange(NSRange(location: selectedRange.location + 1, length: 0))
    }
    return textView
  }
  
  func updateNSView(_ nsView: CustomTextView, context: Context) {
    nsView.string = text
  }
}

#Preview {
  VStack {
    CustomTextViewRepresentable(text: .constant(""))
      .frame(width: 300, height: 200)
      .border(Color.gray, width: 1)
      .padding()
  }
  .padding()
}
