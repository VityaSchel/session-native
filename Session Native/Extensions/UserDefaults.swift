import Foundation

extension UserDefaults {
  public func optionalString(forKey defaultName: String) -> String? {
    let defaults = self
    if let value = defaults.value(forKey: defaultName) {
      return value as? String
    }
    return nil
  }
  
  public func optionalInt(forKey defaultName: String) -> Int? {
    let defaults = self
    if let value = defaults.value(forKey: defaultName) {
      return value as? Int
    }
    return nil
  }
  
  public func optionalBool(forKey defaultName: String) -> Bool? {
    let defaults = self
    if let value = defaults.value(forKey: defaultName) {
      return value as? Bool
    }
    return nil
  }
}
