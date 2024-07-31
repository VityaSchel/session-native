import SwiftData
import Combine
import SwiftUI

@MainActor
class UserManager: ObservableObject {
  @Published var users: [User] = []
  @Published var activeUser: User?
  
  private var container: ModelContainer
  private var cancellables: Set<AnyCancellable> = []
  
  init(container: ModelContainer) {
    self.container = container
    loadUsers()
  }
  
  func loadUsers() {
    do {
      let fetchRequest = FetchDescriptor<User>()
      self.users = try container.mainContext.fetch(fetchRequest)
      if let activeUserID = UserDefaults.standard.string(forKey: "activeUser") {
        if let user = users.first(where: { $0.id.uuidString == activeUserID }) {
          self.activeUser = user
        }
      } else {
        self.activeUser = users[0]
      }
    } catch {
      print("Failed to fetch users: \(error.localizedDescription)")
    }
  }
  
  func saveUsers() {
    do {
      try container.mainContext.save()
      if let activeUser = activeUser {
        UserDefaults.standard.set(activeUser.id.uuidString, forKey: "activeUser")
      } else {
        UserDefaults.standard.removeObject(forKey: "activeUser")
      }
    } catch {
      print("Failed to save users: \(error.localizedDescription)")
    }
  }
  
  func addUser(_ user: User) {
    container.mainContext.insert(user)
    saveUsers()
    loadUsers()
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
