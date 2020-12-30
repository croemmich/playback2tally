import Cocoa
import Defaults

class Manager {
        
    var tally: TalleyConnection?
    var playback: Playback?
    
    var preferenceObservers = [Defaults.Observation]()
    
    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUpdateState(_:)), name: .didUpdateState, object: nil)
        
        setupTally()
        setupPlayback()
        
        self.preferenceObservers = [
            Defaults.observe(keys: .udmHost, .udmPort, options: []) {
                self.setupTally()
            },
            Defaults.observe(keys: .playbackVariant, options: []) {
                self.setupPlayback()
            },
            Defaults.observe(keys: .mittiFeedbackPort, .mittiHost, .mittiPort, options: []) {
                self.setupPlayback()
            }
            
        ]
    }
    
    func stop() {
        NotificationCenter.default.removeObserver(self, name: .didUpdateState, object: nil)
        
        for observer in preferenceObservers {
            observer.invalidate()
        }
    }
    
    func setupPlayback() {
        print("setupPlayback")
        do {
            try playback?.stop()
            playback = initPlaybackVarient(varient: Defaults[.playbackVariant])
            try playback?.start()
        } catch {
            print(error)
        }
    }
    
    func initPlaybackVarient(varient: PlaybackVariant) -> Playback? {
        switch varient {
        case .mitti:
            return Mitti(feedbackPort: UInt16(Defaults[.mittiFeedbackPort]), mittiHost: Defaults[.mittiHost], mittiPort: UInt16(Defaults[.mittiPort]))
        }
    }
    
    func setupTally() {
        print("setupTally")
        
        tally?.disconnect()
        
        tally = TalleyConnection(host: Defaults[.udmHost], port: Defaults[.udmPort])
    }
    
    @objc func onDidUpdateState(_ notification: Notification) {
        let state = notification.userInfo!["state"] as! State
        print("Observed state: playing: \(state.playing) cueName: \(state.cueName) timeTotal: \(state.timeTotal) timeLeft: \(state.timeLeft) timeElapsed: \(state.timeElapsed) previousCueName: \(state.previousCueName) nextCueName: \(state.nextCueName)")

        sendTallyUpdatesForState(state: state)
    }
    
    func sendTallyUpdatesForState(state: State) {
        sendTallyUpdate(Defaults[.udmAddressCueName], state.playing, state.cueName)
        sendTallyUpdate(Defaults[.udmAddressTimeTotal], state.playing, state.timeTotal.stringFromTimeInterval())
        sendTallyUpdate(Defaults[.udmAddressTimeLeft], state.playing, state.timeLeft.stringFromTimeInterval())
        sendTallyUpdate(Defaults[.udmAddressTimeElapsed], state.playing, state.timeElapsed.stringFromTimeInterval())
        sendTallyUpdate(Defaults[.udmAddressPreviousCueName], state.playing, state.previousCueName)
        sendTallyUpdate(Defaults[.udmAddressNextCueName], state.playing, state.nextCueName)
        sendTallyUpdate(Defaults[.udmAddressSelectedCueName], state.playing, state.selectedCueName)
    }
    
    func sendTallyUpdate(_ address: Int, _ isPlaying: Bool, _ display: String) {
        if (address >= 0) {
            let builder = UDMPacketBuilder()
            builder.address(index: UInt8(address))
            if (isPlaying) {
                builder.tally1().brightnessFull()
            }
            builder.display(text: display)
            tally?.send(packet: builder.build())
        }
    }
    
}
