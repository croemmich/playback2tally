import Cocoa
import OSCKit

class Mitti: Playback, OSCPacketDestination {
    
    let state: State!
    var client: OSCClient!
    var server: OSCServer!
    var lastHash: String!
    
    init(feedbackPort: UInt16 = 1234, mittiHost: String = "localhost", mittiPort: UInt16 = 51000) {
        state = State()
        server = OSCServer()
        server.port = feedbackPort
        server.delegate = self
        
        client = OSCClient()
        client.host = mittiHost
        client.port = mittiPort
    }
    
    func start() throws {
        try server.startListening()
        client.send(packet: OSCMessage(with: "/mitti/resendOSCFeedback", arguments: []))
    }
    
    func stop() throws {
        client.disconnect()
        server.stopListening()
    }
    
    func take(message: OSCMessage) {
        switch message.addressPattern {
        case "/mitti/togglePlay":
            let playing = (message.arguments.first as! Int32) == 1
            if (state.playing != playing) {
                state.playing = playing
                state.notify()
            }
        case "/mitti/currentCueName":
            let name = sanitizeCueName(name: (message.arguments.first as! String))
            if (state.cueName != name) {
                state.cueName = name
                state.notify()
            }
        case "/mitti/currentCueTRT":
            let time = parseTime(time: (message.arguments.first as! String))
            if (state.timeTotal != time) {
                state.timeTotal = time
                state.notify()
            }
        case "/mitti/cueTimeLeft":
            let time = parseTime(time: (message.arguments.first as! String))
            if (state.timeLeft != time) {
                state.timeLeft = time
                state.notify()
            }
        case "/mitti/cueTimeElapsed":
            let time = parseTime(time: (message.arguments.first as! String))
            if (state.timeElapsed != time) {
                state.timeElapsed = time
                state.notify()
            }
        case "/mitti/previousCueName":
            let name = sanitizeCueName(name: (message.arguments.first as! String))
            if (state.previousCueName != name) {
                state.previousCueName = name
                state.notify()
            }
        case "/mitti/nextCueName":
            let name = sanitizeCueName(name: (message.arguments.first as! String))
            if (state.nextCueName != name) {
                state.nextCueName = name
                state.notify()
            }
        case "/mitti/selectedCueName":
            let name = sanitizeCueName(name: (message.arguments.first as! String))
            if (state.selectedCueName != name) {
                state.selectedCueName = name
                state.notify()
            }
        default:
            return
        }
    }

    func take(bundle: OSCBundle) {
        // do nothing
    }
    
    func sanitizeCueName(name: String) -> String {
        if (name == "-") {
            return ""
        }
        return name
    }
    
    func parseTime(time: String) -> TimeInterval {
        var mutableTime = time
        if (time.starts(with: "-")) {
            mutableTime.removeFirst()
        }
        let hmsf = mutableTime.split(separator: ":")
        let hours = Int(String(hmsf[0]))! * 3600
        let minutes = Int(String(hmsf[1]))! * 60
        let seconds = Int(String(hmsf[2]))!
        
        return TimeInterval(hours + minutes + seconds)
    }
    
}
