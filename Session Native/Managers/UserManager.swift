import SwiftData
import Combine
import SwiftUI
import MessagePack

@MainActor
class UserManager: ObservableObject {
  @Published var users: [User] = []
  @Published var activeUser: User?
  
  private var container: ModelContainer
  private var cancellables: Set<AnyCancellable> = []
  
  var preview: Bool
  
  init(container: ModelContainer, preview: Bool = false) {
    self.container = container
    self.preview = preview
    loadUsers()
  }
  
  func loadUsers() {
    DispatchQueue.main.async {
      do {
        let fetchRequest = FetchDescriptor<User>()
        self.users = try self.container.mainContext.fetch(fetchRequest)
        if let activeUserID = UserDefaults.standard.string(forKey: "activeUser") {
          if let user = self.users.first(where: { $0.id.uuidString == activeUserID }),
             let mnemonic = self.preview ? "" : readStringFromKeychain(account: user.sessionId, service: "mnemonic") {
            request([
              "type": "set_session",
              "mnemonic": .string(mnemonic)
            ]) { response in
              self.activeUser = user
            }
          }
        } else if !self.users.isEmpty {
          let user = self.users[0]
          if let mnemonic = self.preview ? "" : readStringFromKeychain(account: user.sessionId, service: "mnemonic") {
            request([
              "type": "set_session",
              "mnemonic": .string(mnemonic)
            ]) { response in
              self.activeUser = user
            }
          }
        }
      } catch {
        print("Failed to fetch users: \(error.localizedDescription)")
      }
    }
  }
  
  func saveUsers() {
    DispatchQueue.main.async {
      do {
        try self.container.mainContext.save()
        if let activeUser = self.activeUser {
          UserDefaults.standard.set(activeUser.id.uuidString, forKey: "activeUser")
        } else {
          UserDefaults.standard.removeObject(forKey: "activeUser")
        }
      } catch {
        print("Failed to save users: \(error.localizedDescription)")
      }
    }
  }
  
  func addUser(_ user: User, mnemonic: String) {
    request([
      "type": "set_session",
      "mnemonic": .string(mnemonic),
      "displayName": .string(user.displayName ?? ""),
      "avatar": user.avatar != nil ? .binary(user.avatar!) : .nil
    ]) { response in
      self.container.mainContext.insert(user)
      self.activeUser = user
      self.saveUsers()
      let fetchRequest = FetchDescriptor<User>()
      do {
        self.users = try self.container.mainContext.fetch(fetchRequest)
      } catch {
        print("Failed to fetch users: \(error.localizedDescription)")
      }
    }
  }
  
  func removeUser(_ user: User) {
    container.mainContext.delete(user)
    if activeUser?.id == user.id {
      activeUser = nil
    }
    saveUsers()
    loadUsers()
  }
  
  func setActiveUser(_ user: User?) {
    activeUser = user
    saveUsers()
  }
}
