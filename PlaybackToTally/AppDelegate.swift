import Cocoa

import Preferences
import SwiftyUserDefaults

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    var statusItem: NSStatusItem!
    
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var statusMenuItem: NSMenuItem!
    @IBOutlet weak var cueMenuItem: NSMenuItem!
    @IBOutlet weak var timeTotalMenuItem: NSMenuItem!
    @IBOutlet weak var timeLeftMenuItem: NSMenuItem!
    @IBOutlet weak var timeElapsedMenuItem: NSMenuItem!
    @IBOutlet weak var previousCueMenuItem: NSMenuItem!
    @IBOutlet weak var nextCueMenuItem: NSMenuItem!

    var renderMenuUpdates = false
    var lastState : State?
    
    var mitti: Mitti!
    var tally: TalleyConnection!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUpdateState(_:)), name: .didUpdateState, object: nil)
            
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Pb2T"
        statusItem.menu = menu
        statusItem.menu?.delegate = self
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        mitti = Mitti(feedbackPort: UInt16(Defaults.mittiFeedbackPort))
        do {
            try mitti.start()
        } catch {
            print("Unexpected error: \(error).")
        }
        
        tally = TalleyConnection(host: Defaults.udmHost, port: Defaults.udmPort)
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        try! mitti.stop()

        return NSApplication.TerminateReply.terminateNow
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        renderMenuUpdates = true
        renderMenuState()
    }
    
    func menuDidClose(_ menu: NSMenu) {
        renderMenuUpdates = false
    }

    
    func renderMenuState() {
        if let s = lastState {
            statusMenuItem?.title = "Status: " + (s.playing ? "Playing" : "Stopped" )
            cueMenuItem?.isHidden = false
            cueMenuItem?.title = "Cue: " + (s.cueName != "" ? s.cueName : "N/A")
            timeTotalMenuItem?.isHidden = false
            timeTotalMenuItem?.title = "Time Total: " + s.timeTotal.stringFromTimeInterval()
            timeLeftMenuItem?.isHidden = false
            timeLeftMenuItem?.title = "Time Left: " + s.timeLeft.stringFromTimeInterval()
            timeElapsedMenuItem?.isHidden = false
            timeElapsedMenuItem?.title = "Time Elapsed: " + s.timeElapsed.stringFromTimeInterval()
            previousCueMenuItem?.isHidden = false
            previousCueMenuItem?.title = "Prev Cue: " + (s.previousCueName != "" ? s.previousCueName : "N/A")
            nextCueMenuItem?.isHidden = false
            nextCueMenuItem?.title = "Next Cue: " + (s.nextCueName != "" ? s.nextCueName : "N/A")
        } else {
            statusMenuItem?.title = "Status: Not Connected"
            cueMenuItem?.isHidden = true
            timeTotalMenuItem?.isHidden = true
            timeLeftMenuItem?.isHidden = true
            timeElapsedMenuItem?.isHidden = true
            previousCueMenuItem?.isHidden = true
            nextCueMenuItem?.isHidden = true
        }
    }
    
    
    @objc func onDidUpdateState(_ notification: Notification) {
        let state = notification.userInfo!["state"] as! State
        self.lastState = state
        
        if (renderMenuUpdates) {
            renderMenuState()
        }
        
        print("Observed state: playing: \(state.playing) cueName: \(state.cueName) timeTotal: \(state.timeTotal) timeLeft: \(state.timeLeft) timeElapsed: \(state.timeElapsed) previousCueName: \(state.previousCueName) nextCueName: \(state.nextCueName)")

        let builder = UDMPacketBuilder()
        if (state.playing) {
            builder.display(text: String(Int(state.timeLeft))).tally1().brightnessFull()
        }
        tally.send(packet: builder.build())
    }
    
    
    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            GeneralPreferenceViewController(),
            TallyPreferenceViewController(),
            PlaybackPreferenceViewController()
        ],
        style: .segmentedControl,
        animated: true
    )
    
    @IBAction
    func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
        openPreferences()
    }
    
    func openPreferences() {
        preferencesWindowController.show()
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose), name: NSWindow.willCloseNotification, object: preferencesWindowController.window)
        NSApp.setActivationPolicy(.regular)
    }
    
    @objc func windowWillClose() {
        NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: preferencesWindowController.window)
        NSApp.setActivationPolicy(.accessory)
    }
    
}

