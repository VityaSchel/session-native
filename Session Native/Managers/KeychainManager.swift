import Foundation
import Security

func saveToKeychain(account: String, service: String, data: Data) -> OSStatus {
  let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: account,
    kSecAttrService as String: service,
    kSecValueData as String: data
  ]
  
  SecItemDelete(query as CFDictionary)
  
  return SecItemAdd(query as CFDictionary, nil)
}

func saveToKeychain(account: String, service: String, value: String) -> OSStatus {
  if let data = value.data(using: .utf8) {
    return saveToKeychain(account: account, service: service, data: data)
  }
  return errSecParam
}

func readDataFromKeychain(account: String, service: String) -> Data? {
  let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: account,
    kSecAttrService as String: service,
    kSecReturnData as String: kCFBooleanTrue!,
    kSecMatchLimit as String: kSecMatchLimitOne
  ]
  
  var dataTypeRef: AnyObject?
  let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
  
  if status == errSecSuccess {
    return dataTypeRef as? Data
  }
  
  return nil
}

func readStringFromKeychain(account: String, service: String) -> String? {
  if let data = readDataFromKeychain(account: account, service: service) {
    return String(data: data, encoding: .utf8)
  }
  return nil
}

func deleteFromKeychain(account: String, service: String) {
  let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: account,
    kSecAttrService as String: service
  ]
  
  SecItemDelete(query as CFDictionary)
}
