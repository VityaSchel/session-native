import Foundation
import UserNotifications

func requestNotificationAuthorization() {
  let center = UNUserNotificationCenter.current()
  
  center.getNotificationSettings { settings in
    switch settings.authorizationStatus {
    case .notDetermined:
      center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if granted {
          print("Notification access granted.")
        } else {
          print("Notification access denied.\(String(describing: error?.localizedDescription))")
        }
      }
      return
    case .denied:
      return
    case .authorized:
      return
    default:
      return
    }
  }
}

func pushNotification(id: String, title: String, body: String) {
  let content: UNMutableNotificationContent = UNMutableNotificationContent()
  content.title = title
  content.body = body
  content.sound = .default
  content.interruptionLevel = .active
  let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
  UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}
