import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
  var process: Process?
  private var outputPipe: Pipe?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    startSidecar()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    terminateSidecar()
  }

  func startSidecar() {
    if let binaryPath = Bundle.main.path(forResource: "backend", ofType: nil) {
      process = Process()
      process?.environment = [
        "NODE_TLS_REJECT_UNAUTHORIZED": "0"
      ]
      process?.executableURL = URL(fileURLWithPath: binaryPath)
      
      outputPipe = Pipe()
      process?.standardOutput = outputPipe
      process?.standardError = outputPipe

      do {
        try process?.run()
        print("Sidecar binary running")
        NSLog("Sidecar binary running")
        
        readProcessOutput()
      } catch {
        print("Failed to run sidecar binary: \(error)")
        NSLog("Failed to run sidecar binary: \(error)")
        SidecarManager.shared.isSidecarRunning = true
      }
    }
  }
  
  private func readProcessOutput() {
    let fileHandle = outputPipe!.fileHandleForReading
    
    fileHandle.readabilityHandler = { handle in
      let data = handle.availableData
      if data.isEmpty {
        if let process = self.process, !process.isRunning {
          print("Process has terminated")
          NSLog("Sidecar has terminated")
          handle.readabilityHandler = nil
          SidecarManager.shared.isSidecarRunning = true
        }
        return
      }
      
      if let outputString = String(data: data, encoding: .utf8) {
        print("Sidecar Output: \(outputString)")
        NSLog("Sidecar Output: \(outputString)")
        
        if outputString.contains("Server listening") {
          DispatchQueue.main.async {
            SidecarManager.shared.isSidecarRunning = true
          }
//          handle.readabilityHandler = nil
        }
      }
    }
  }

  func terminateSidecar() {
    process?.terminate()
    print("Sidecar binary terminated")
  }
}
