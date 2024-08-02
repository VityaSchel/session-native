import Foundation

func getSessionIdPlaceholder(sessionId: String) -> String {
  return "(" + sessionId.prefix(4) + "..." + sessionId.suffix(4) + ")"
}

func isSessionID(_ string: String) -> Bool {
  let pattern = "^05[0-9a-fA-F]+$"
  
  let regex = try! NSRegularExpression(pattern: pattern)
  
  let range = NSRange(location: 0, length: string.utf16.count)
  let match = regex.firstMatch(in: string, options: [], range: range)
  
  return match != nil
}
