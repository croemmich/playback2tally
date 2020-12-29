import Cocoa
import Foundation
import Preferences

class StatusMenuState: NSObject, NSMenuDelegate {
    
    weak var menu : NSMenu!
    
    var statusItem: NSStatusItem!
    
    weak var statusMenuItem: NSMenuItem!
    weak var cueMenuItem: NSMenuItem!
    weak var timeTotalMenuItem: NSMenuItem!
    weak var timeLeftMenuItem: NSMenuItem!
    weak var timeElapsedMenuItem: NSMenuItem!
    weak var previousCueMenuItem: NSMenuItem!
    weak var nextCueMenuItem: NSMenuItem!

    var renderMenuUpdates = false
    var lastState : State?
    
    init(_ menu: NSMenu) {
        self.menu = menu
    }
    
    public func bind(_ menu: NSMenu) {
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUpdateState(_:)), name: .didUpdateState, object: nil)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let image = NSImage(named: "StatusIcon")
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.menu = menu
        statusItem.menu?.delegate = self
        
        statusMenuItem = menu.item(withTag: 1)
        cueMenuItem = menu.item(withTag: 2)
        timeTotalMenuItem = menu.item(withTag: 3)
        timeLeftMenuItem = menu.item(withTag: 4)
        timeElapsedMenuItem = menu.item(withTag: 5)
        previousCueMenuItem = menu.item(withTag: 6)
        nextCueMenuItem = menu.item(withTag: 7)
    }
    
    public func unbind() {
        NotificationCenter.default.removeObserver(self, name: .didUpdateState, object: nil)
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
    }
    
}
