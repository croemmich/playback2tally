import Cocoa

class State: NSObject, NSCopying {
    
    public var playing: Bool = false
    
    public var cueName: String = ""
    
    public var timeTotal: TimeInterval = 0
    
    public var timeLeft: TimeInterval = 0
    
    public var timeElapsed: TimeInterval = 0
    
    public var previousCueName: String = ""
    
    public var nextCueName: String = ""
    
    public var selectedCueName: String = ""
    
    func notify() {
        NotificationCenter.default.post(name: .didUpdateState, object: nil, userInfo: ["state": self.copy()])
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let s = State()
        s.playing = playing
        s.cueName = cueName
        s.timeTotal = timeTotal
        s.timeLeft = timeLeft
        s.timeElapsed = timeElapsed
        s.previousCueName = previousCueName
        s.nextCueName = nextCueName
        s.selectedCueName = selectedCueName
        return s
    }
    
}

extension Notification.Name {
    static let didUpdateState = Notification.Name("didUpdateState")
}
