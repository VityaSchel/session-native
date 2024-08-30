import SwiftData
import SwiftUI

@MainActor
class ConnectionStatusManager: ObservableObject {
  @Published var connected: Bool
  @Published var error: String
  
  init() {
    connected = true
    error = ""
  }
  
  func setConnected(_ connected: Bool) {
    self.connected = connected
  }
  
  func setError(_ error: String) {
    self.error = error
  }
}
