import Foundation

func getSessionIdPlaceholder(sessionId: String) -> String {
  return "(" + sessionId.prefix(4) + "..." + sessionId.suffix(4) + ")"
}
