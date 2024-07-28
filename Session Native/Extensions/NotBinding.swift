import SwiftUI

extension Binding where Value == Bool {
  var not: Binding<Value> {
    Binding<Value> (
      get: { !self.wrappedValue },
      set: { self.wrappedValue = $0}
    )
  }
}
