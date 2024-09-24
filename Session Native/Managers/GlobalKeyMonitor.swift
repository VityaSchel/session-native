import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

class GlobalKeyMonitor: ObservableObject {
  var onFilePasted: ((_: Data, _: String, _: String) -> Void)?
  
  private var eventMonitor: Any?
  
  init() {
    eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      self?.handleKeyDown(event: event)
      return event
    }
  }
  
  private func handleKeyDown(event: NSEvent) {
    if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
      let pasteboard = NSPasteboard.general
      let pastedFileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [NSURL] ?? []
      
      DispatchQueue.main.async {
        for fileURL in pastedFileURLs {
          do {
            if(fileURL.hasDirectoryPath == false) {
              let data = try Data(contentsOf: fileURL as URL)
              if let fileExtension = fileURL.pathExtension {
                let type = UTType(filenameExtension: fileExtension)
                if let filename = fileURL.lastPathComponent {
                  self.onFilePasted?(data, filename, type?.preferredMIMEType ?? "text/plain")
                }
              }
            }
          } catch {
            print("Error loading pasted data from \(fileURL): \(error)")
          }
        }
      }
    }

  }
  
  deinit {
    if let monitor = eventMonitor {
      NSEvent.removeMonitor(monitor)
    }
  }
}
