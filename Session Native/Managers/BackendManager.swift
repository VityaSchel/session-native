import Foundation
import MessagePack

class SidecarManager: ObservableObject {
  static let shared = SidecarManager()
  
  @Published var isSidecarRunning: Bool = false
  
  private init() {}
}

class UnixDomainSocketClient {
  private let socketPath: String
  private let dispatchQueue: DispatchQueue
  private var responseHandlers: [String: (MessagePackValue) -> Void] = [:]
  private var eventHandlers: [String: [([MessagePackValue : MessagePackValue]) -> Void]] = [:]
  private var listening = false
  private var listeningSocket: Int32 = -1
  
  init(socketPath: String) {
    self.socketPath = socketPath
    self.dispatchQueue = DispatchQueue(label: "UnixDomainSocketClientQueue", attributes: .concurrent)
    startListening()
  }
  
  func sendMessage(_ message: MessagePackValue, completion: @escaping (MessagePackValue) -> Void) {
    let identifier = String(Int.random(in: 0...Int.max))
    let requestId = MessagePackValue.string(identifier)
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
    
    responseHandlers[identifier] = completion
    
    dispatchQueue.async { [weak self] in
      self?.sendData(data: data)
    }
  }
  
  private func sendData(data: Data) {
    let payload: Data = data + Data(Array(repeating: 0x03, count: 64))
    payload.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
      let bytesSent = send(self.listeningSocket, ptr.baseAddress!, payload.count, 0)
      if bytesSent < 0 {
        print("Failed to send data")
      }
    }
  }
  
  private func startListening() {
    dispatchQueue.async { [weak self] in
      guard let self = self else { return }
      self.listening = true
      
      var addr = sockaddr_un()
      addr.sun_family = sa_family_t(AF_UNIX)
      strcpy(&addr.sun_path, self.socketPath)
      
      self.listeningSocket = socket(AF_UNIX, SOCK_STREAM, 0)
      guard self.listeningSocket != -1 else {
        print("Failed to create socket for listening")
        return
      }
      
      let size = MemoryLayout.size(ofValue: addr)
      let connected = withUnsafePointer(to: &addr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
          connect(self.listeningSocket, $0, socklen_t(size))
        }
      }
      
      guard connected != -1 else {
        print("Failed to connect to socket for listening")
        return
      }
      
      var receivedData = Data()
      
      while self.listening == true {
        var buffer = [UInt8](repeating: 0, count: 1024)
        let bytesRead = recv(self.listeningSocket, &buffer, buffer.count, 0)
        
        if bytesRead > 0 {
          receivedData.append(buffer, count: bytesRead)
          
          if bytesRead < 1024 {
            do {
              let value = try unpack(receivedData)
              self.handleIncomingMessage(value.value)
              receivedData.removeAll()
            } catch {
              print("Failed to decode incoming message")
            }
          }
        }
      }
      
      close(self.listeningSocket)
      self.listeningSocket = -1
    }
  }
  
  private func handleIncomingMessage(_ message: MessagePackValue) {
    if case MessagePackValue.map(let dataMap) = message,
       let requestId = dataMap[MessagePackValue.string("requestId")]?.stringValue,
       let handler = responseHandlers[requestId] {
      handler(message)
      responseHandlers.removeValue(forKey: requestId)
    } else {
      if case MessagePackValue.map(let dataMap) = message,
         let event = dataMap[MessagePackValue.string("event")]?.stringValue {
        if let handlers = eventHandlers[event] {
          for handler in handlers {
            handler(dataMap)
          }
        }
      }
    }
  }
  
  func on(event: String, handler: @escaping ([MessagePackValue : MessagePackValue]) -> Void) {
    if self.eventHandlers[event] == nil {
      self.eventHandlers[event] = []
    }
    self.eventHandlers[event]?.append(handler)
  }
  
  func off(event: String, handler: @escaping ([MessagePackValue : MessagePackValue]) -> Void) {
    self.eventHandlers[event]?.removeAll(where: { $0 as AnyObject === handler as AnyObject })
    if self.eventHandlers[event]?.isEmpty == true {
      self.eventHandlers.removeValue(forKey: event)
    }
  }
  
  func stopListening() {
    listening = false
    
    if listeningSocket != -1 {
      close(listeningSocket)
      listeningSocket = -1
    }
  }
}

let backendSocketPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "dev.hloth.Session-Native")!
  .appendingPathComponent("tmp/bun_socket")
  .path

let backendApiClient = UnixDomainSocketClient(socketPath: backendSocketPath)

func request(_ message: MessagePackValue, _ completion: @escaping (MessagePackValue) -> Void = { _ in }) {
  backendApiClient.sendMessage(message) { response in
    completion(response)
  }
}
