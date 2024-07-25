import SwiftUI

struct HexCharacterView: View {
  @State private var currentCharacter: String = ""
  @State private var iterations: Int
  @State private var finalCharacter: String
  @State private var currentIteration: Int = 0
  private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
  
  init(finalCharacter: String) {
    self._finalCharacter = State(initialValue: finalCharacter)
    self._iterations = State(initialValue: Int.random(in: 0...20))
    self._currentCharacter = State(initialValue: HexCharacterView.randomHexCharacter())
  }
  
  var body: some View {
    Text(currentCharacter)
      .font(.system(size: 18, design: .monospaced))
      .onReceive(timer) { _ in
        if currentIteration < iterations {
          currentCharacter = HexCharacterView.randomHexCharacter()
          currentIteration += 1
        } else {
          currentCharacter = finalCharacter
          timer.upstream.connect().cancel()
        }
      }
  }
  
  static func randomHexCharacter() -> String {
    let hexChars = "0123456789abcdef"
    return String(hexChars.randomElement()!)
  }
}

struct SessionIdAnimation: View {
  let finalString: String
  
  var body: some View {
    VStack {
      ForEach(0..<2) { row in
        HStack(spacing: 0) {
          ForEach(0..<33) { col in
            let index = row * 33 + col
            if index < finalString.count {
              let character = finalString[finalString.index(finalString.startIndex, offsetBy: index)]
              HexCharacterView(finalCharacter: String(character))
            } else {
              HexCharacterView(finalCharacter: " ")
            }
          }
        }
      }
    }
    .padding()
  }
}

#Preview {
  SessionIdAnimation(finalString: "05aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
}
