import Foundation
import MessagePack

class UnixDomainSocketClient {
  private let socketPath: String
  private let dispatchQueue: DispatchQueue
  private var responseHandlers: [Int: (MessagePackValue) -> Void] = [:]
  
  init(socketPath: String) {
    self.socketPath = socketPath
    self.dispatchQueue = DispatchQueue(label: "UnixDomainSocketClientQueue", attributes: .concurrent)
  }
  
  func sendMessage(_ message: MessagePackValue, completion: @escaping (MessagePackValue) -> Void) {
    let identifier = Int.random(in: 0...Int.max)
    let requestId = MessagePackValue.int(Int64(identifier))
    var data: Data
    if case MessagePackValue.map(let dataMap) = message {
      var updatedDataMap = dataMap
      updatedDataMap[MessagePackValue.string("requestId")] = requestId
      let updatedMessage = MessagePackValue.map(updatedDataMap)
      data = pack(updatedMessage)
    } else {
      print("Error: The message is not a map")
      data = pack(message)
    }
    
    dispatchQueue.async { [weak self] in
      self?.responseHandlers[identifier] = completion
      
      var addr = sockaddr_un()
      addr.sun_family = sa_family_t(AF_UNIX)
      strcpy(&addr.sun_path, self?.socketPath)
      
      let sockfd = socket(AF_UNIX, SOCK_STREAM, 0)
      guard sockfd != -1 else {
        print("Failed to create socket")
        return
      }
      
      defer {
        close(sockfd)
      }
      
      let size = MemoryLayout.size(ofValue: addr)
      let connected = withUnsafePointer(to: &addr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
          connect(sockfd, $0, socklen_t(size))
        }
      }
      
      guard connected != -1 else {
        print("Failed to connect to socket")
        return
      }
      
      data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
        send(sockfd, ptr.baseAddress!, data.count, 0)
      }
      
      var buffer = [UInt8](repeating: 0, count: 1024)
      let bytesRead = recv(sockfd, &buffer, buffer.count, 0)
      
      if bytesRead > 0 {
        do {
          let value = try unpack(Data(buffer))
          self?.dispatchQueue.async {
            self?.responseHandlers[identifier]?(value.value)
            self?.responseHandlers.removeValue(forKey: identifier)
          }
        } catch {
          print("Failed to decode response")
        }
      } else {
        self?.dispatchQueue.async {
          self?.responseHandlers[identifier]?(MessagePackValue("No response from server"))
          self?.responseHandlers.removeValue(forKey: identifier)
        }
      }
    }
  }
}

let backendSocketPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "dev.hloth.Session-Native")!
  .appendingPathComponent("tmp/bun_socket")
  .path

let backendApiClient = UnixDomainSocketClient(socketPath: backendSocketPath)

func request(_ message: MessagePackValue, _ completion: @escaping (MessagePackValue) -> Void) {
  backendApiClient.sendMessage(message) { response in
    completion(response)
  }
}
