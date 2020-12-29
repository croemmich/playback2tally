import Cocoa
import Network

class TalleyConnection: NSObject {

    var host: String!
    var port: Int!

    let lock = NSLock()
    var connection: NWConnection!

    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }

    func establish() {
        lock.lock()
        if (connection == nil) {
            connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: UInt16(port))!, using: .udp)
            connection.stateUpdateHandler = { [unowned self] (newState) in
                switch (newState) {
                case .ready:
                    self.lock.unlock()
                case .failed(let error):
                    print(error)
                    self.connection = nil
                    self.lock.unlock()
                case .cancelled:
                    self.connection = nil
                    self.lock.unlock()
                default:
                    break
                }
            }
            self.connection.start(queue: .global())
        } else {
            lock.unlock()
        }
    }

    func disconnect() {
        lock.lock()
        connection?.cancel()
        connection = nil
        lock.unlock()
    }

    func send(packet: UDMPacket) {
        establish()

        lock.lock()
        let dataBytes = packet.getBytes()
        let data = Data(bytes: dataBytes, count: dataBytes.count)
        connection?.send(content: data, contentContext: .defaultMessage, isComplete: true, completion: .idempotent)
        lock.unlock()
    }

}
