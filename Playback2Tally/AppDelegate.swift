import Cocoa

import Preferences
import SwiftyUserDefaults

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
        
    @IBOutlet weak var menu: NSMenu!
    
    var statusMenu: StatusMenuState?
    
    var mitti: Mitti!
    var tally: TalleyConnection!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUpdateState(_:)), name: .didUpdateState, object: nil)
        
        statusMenu = StatusMenuState(menu)
        statusMenu?.bind(menu)
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

        statusMenu?.unbind()
        
        return NSApplication.TerminateReply.terminateNow
    }
    

    @objc func onDidUpdateState(_ notification: Notification) {
        let state = notification.userInfo!["state"] as! State
        
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

