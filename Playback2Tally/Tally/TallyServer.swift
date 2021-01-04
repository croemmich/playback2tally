import Cocoa
import Network

class TallyServer {

    let queue = DispatchQueue(label: "Tally server operations", qos: .userInitiated)
    
    let port: NWEndpoint.Port
    let proto: String
    
    var listener: NWListener?
    var connections = [NWConnection]()
    
    init(port: Int, proto: String = "tcp") {
        self.port = NWEndpoint.Port(rawValue: UInt16(port))!
        self.proto = proto
    }
    
    func shouldReceive() -> Bool {
        if (proto == "udp") {
            return false
        }
        return true
    }
    
    func createNWParameters() -> NWParameters {
        if (proto == "udp") {
            return .udp
        }
        
        let options = NWProtocolTCP.Options()
        options.connectionTimeout = 3
        return NWParameters(tls: nil, tcp: options)
    }
    
    func start() {
        print("TallyServer: enqueuing start")
        
        queue.async { [unowned self] in
            if (listener != nil) {
                print("TallyServer: listener already started")
                return
            }
            
            do {
                listener = try NWListener(using: createNWParameters(), on: self.port)
            } catch {
                print("TallyServer: failed to listen, error: \(error)")
                enqueueStart(.now() + .seconds(2))
                return
            }
            
            listener!.stateUpdateHandler = self.stateDidChange(to:)
            listener!.newConnectionHandler = self.didAccept(conn:)
            listener!.start(queue: DispatchQueue(label: "Tally server listen queue", qos: .utility))
            
            print("TallyServer: listening on :\(port)")
        }
    }
    
    func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case .failed(let error):
            stop(error: error)
        default:
            break
        }
    }

    private func didAccept(conn: NWConnection) {
        print("TallyServer: new connection, conn: \(conn)")
        queue.async { [unowned self] in
            connections.append(conn)
            doReceive(conn)
            conn.start(queue: .global(qos: .utility))
        }
    }
    
    private func doReceive(_ conn: NWConnection) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 18) { [unowned self] (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                print("TallyServer: did receive, data: \(data as NSData)")
                if (data.count == 18) {
                    let packet = UDMPacket(bytes: [UInt8](data))
                    NotificationCenter.default.post(name: .didUpdateTally, object: nil, userInfo: ["packet": packet])
                } else {
                    print("TallyServer: incorrect packet length")
                }
            }
            if isComplete && proto == "tcp" {
                connectionDidEnd(conn)
            } else if let error = error {
                connectionDidEnd(conn, error)
            } else {
                self.doReceive(conn)
            }
        }
    }
    
    private func connectionDidEnd(_ conn: NWConnection, _ error: Error? = nil) {
        print("TallyServer: connectionDidEnd, connection: \(conn)")
        if error != nil {
            print("TallyServer: connection failed, error: \(error!)")
        }
        queue.async { [weak self] in
            self?.connections.removeAll(where: { $0.endpoint.hashValue == conn.endpoint.hashValue })
        }
    }
    
    func disconnect() {
        stop(error: nil)
    }

    private func stop(error: Error?) {
        print("TallyServer: enqueuing stop")
        
        queue.async { [unowned self] in
            if (listener == nil) {
                print("TallyServer: not listening")
                return
            }
            
            listener!.stateUpdateHandler = nil
            listener!.newConnectionHandler = nil
            listener!.cancel()
            listener = nil
            
            for conn in connections {
                conn.cancel()
            }
            connections.removeAll()
            
            if (error != nil) {
                print("TallyServer: listening did fail, error: \(error!)")
                enqueueStart(.now() + .seconds(2))
            }
        }
    }
    
    private func enqueueStart(_ deadline: DispatchTime) {
        print("TallyServer: enqueuing restart")
        queue.asyncAfter(deadline: deadline, execute: { [weak self] in
            self?.start()
        })
    }
    
}

extension Notification.Name {
    static let didUpdateTally = Notification.Name("didUpdateTally")
}
