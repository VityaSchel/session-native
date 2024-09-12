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
      if let pastedFileURLString = pasteboard.string(forType: .fileURL), let fileURL = URL(string: pastedFileURLString) {
        DispatchQueue.main.async {
          do {
            let data = try Data(contentsOf: fileURL)
            let fileExtension = fileURL.pathExtension
            let type = UTType(filenameExtension: fileExtension)
            self.onFilePasted?(data, fileURL.lastPathComponent, type?.preferredMIMEType ?? "text/plain")
          } catch {
            print("Error loading pasted image data: \(error)")
          }
        }
      } else if let imageData = pasteboard.data(forType: .png) {
        self.onFilePasted?(imageData, "image.png", "image/png")
      } else if let imageData = pasteboard.data(forType: .tiff) {
        self.onFilePasted?(imageData, "image.tiff", "image/tiff")
      } else if let imageData = pasteboard.data(forType: .pdf) {
        self.onFilePasted?(imageData, "document.pdf", "application/pdf")
      }
    }
  }
  
  deinit {
    if let monitor = eventMonitor {
      NSEvent.removeMonitor(monitor)
    }
  }
}
