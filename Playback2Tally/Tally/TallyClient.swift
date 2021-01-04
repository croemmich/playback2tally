import Cocoa
import Network

class TallyClient {

    var isRunning = false
    var isReady = false
    
    let host: NWEndpoint.Host
    let port: NWEndpoint.Port
    let proto: String
        
    var connection: NWConnection?
    let queue = DispatchQueue(label: "Tally client operations", qos: .userInitiated)
    
    init(host: String, port: Int, proto: String = "tcp") {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: UInt16(port))!
        self.proto = proto
    }
    
    func shouldReceive() -> Bool {
        if (proto == "udp") {
            return false
        }
        return true
    }
    
    func start() {
        queue.async { [unowned self] in
            if (isRunning) {
                print("TallyClient: connection already running")
                return
            }
            
            isRunning = true
            
            connection = NWConnection(host: self.host, port: self.port, using: createNWParameters())
            connection!.stateUpdateHandler = stateDidChange(to:)
            if (shouldReceive()) {
                doReceive(connection!)
            }
            connection!.start(queue: DispatchQueue(label: "Tally client requests", qos: .utility))
            
            print("TallyClient: connection started \(host) \(port)")
        }
    }
    
    func createNWParameters() -> NWParameters {
        if (proto == "udp") {
            return .udp
        }
        
        let options = NWProtocolTCP.Options()
        options.connectionTimeout = 3
        return NWParameters(tls: nil, tcp: options)
    }
    
    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            stop(error: error)
        case .ready:
            onReady()
        case .failed(let error):
            stop(error: error)
        default:
            break
        }
    }
    
    private func onReady() {
        print("TallyClient: connection ready")
        queue.async { [unowned self] in
            isReady = true
        }
    }
    
    private func doReceive(_ conn: NWConnection) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [unowned self] (_, _, isComplete, error) in
            if isComplete || error != nil {
                return
            } else {
                self.doReceive(conn)
            }
        }
    }
    
    func disconnect() {
        stop(error: nil)
    }

    private func stop(error: Error?) {
        queue.async { [unowned self] in
            if (!isRunning || connection == nil) {
                print("TallyClient: connection not running")
                return
            }
            
            connection!.stateUpdateHandler = nil
            connection!.cancel()
            
            isRunning = false
            isReady = false
            
            if (error != nil) {
                print("TallyClient: connection did fail, error: \(error!)")
                print("TallyClient: reconnecting in 2 seconds")
                queue.asyncAfter(deadline: .now() + .seconds(2), execute: { [weak self] in
                    self?.start()
                })
            }
        }
    }
    
    func send(packet: UDMPacket) {
        queue.async { [unowned self] in
            if (!isReady || connection == nil) {
                print ("Tally: did not send message, connection not ready")
                return
            }
            
            let dataBytes = packet.getBytes()
            let data = Data(bytes: dataBytes, count: dataBytes.count)
            
            connection!.send(content: data, contentContext: .defaultMessage, isComplete: true, completion: .contentProcessed( { [unowned self] error in
                    if let error = error {
                        self.stop(error: error)
                        return
                    }
                    print("TallyClient: did send, data: \(data as NSData)")
                })
            )
        }
    }
    
}
