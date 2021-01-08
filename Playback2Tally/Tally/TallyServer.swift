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
        
        queue.async { [weak self] in
            guard let self = self else { return }

            if (self.listener != nil) {
                print("TallyServer: listener already started")
                return
            }
            
            do {
                self.listener = try NWListener(using: self.createNWParameters(), on: self.port)
            } catch {
                print("TallyServer: failed to listen, error: \(error)")
                self.enqueueStart(.now() + .seconds(2))
                return
            }
            
            self.listener!.stateUpdateHandler = self.stateDidChange(to:)
            self.listener!.newConnectionHandler = self.didAccept(conn:)
            self.listener!.start(queue: DispatchQueue(label: "Tally server listen queue", qos: .utility))
            
            print("TallyServer: listening on :\(self.port)")
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
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if (self.proto) == "tcp" {
                self.connections.append(conn)
            }
            self.doReceive(conn)
            conn.start(queue: .global(qos: .utility))
        }
    }
    
    private func doReceive(_ conn: NWConnection) {
        if (self.proto == "tcp") {
            conn.receive(minimumIncompleteLength: 1, maximumLength: 18) { [weak self] (data, _, isComplete, error) in
                self?.onReceive(conn: conn, data: data, isComplete: isComplete, error: error)
            }
        } else {
            conn.receiveMessage { [weak self] (data, _, isComplete, error) in
                self?.onReceive(conn: conn, data: data, isComplete: isComplete, error: error)
            }
        }
    }

    private func onReceive(conn: NWConnection, data: Data?, isComplete: Bool, error: NWError?) {
        if let data = data, !data.isEmpty {
            print("TallyServer: did receive, data: \(data as NSData)")
            if (data.count == 18) {
                let packet = UDMPacket(bytes: [UInt8](data))
                NotificationCenter.default.post(name: .didUpdateTally, object: nil, userInfo: ["packet": packet])
            } else {
                print("TallyServer: incorrect packet length")
            }
        }
        if isComplete && self.proto == "tcp" {
            self.connectionDidEnd(conn)
        } else if let error = error {
            self.connectionDidEnd(conn, error)
        } else {
            self.doReceive(conn)
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
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if (self.listener == nil) {
                print("TallyServer: not listening")
                return
            }
            
            self.listener!.stateUpdateHandler = nil
            self.listener!.newConnectionHandler = nil
            self.listener!.cancel()
            self.listener = nil
            
            for conn in self.connections {
                conn.cancel()
            }
            self.connections.removeAll()
            
            if (error != nil) {
                print("TallyServer: listening did fail, error: \(error!)")
                self.enqueueStart(.now() + .seconds(2))
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
