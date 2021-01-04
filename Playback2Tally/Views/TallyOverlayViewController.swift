import Cocoa
import Defaults
import Preferences

final class TallyOverlayViewController: NSViewController, NSWindowDelegate {
    
    var observation: Defaults.Observation?
    var packets = [UInt8:UDMPacket]()
    
    @IBOutlet var tallyView: TallyOverlayView!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window?.delegate = self
        view.window?.canHide = false
        view.window?.styleMask = [.resizable]
        view.window?.isOpaque = true
        view.window?.isMovableByWindowBackground = true
        view.window?.level = .floating
        
        observation = Defaults.observe(keys: .tallyOverlayTallyAddress, .tallyOverlayStyle, .tallyOverlayShowLabel, .tallyOverlayOpacity, .tallyOverlayTallyColor1, .tallyOverlayTallyColor2, .tallyOverlayTallyColorBoth, .tallyOverlayLocked, .tallyOverlayHidden, options: []) { [weak self] in
            self?.redraw()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUpdateTally(_:)), name: .didUpdateTally, object: nil)
        
        redraw()
    }
    
    func windowWillClose(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: .didUpdateState, object: nil)
        
        observation?.invalidate()
    }
    
    
    func redraw() {
        DispatchQueue.main.async(qos:.userInteractive) { [weak self] in
            guard let self = self else { return }
            
            if (Defaults[.tallyOverlayHidden]) {
                self.view.window?.canHide = true
                self.view.window?.orderOut(nil)
                return // nothing more to do if we're hiding the window
            } else {
                self.view.window?.canHide = false
                self.view.window?.orderFront(nil)
            }
            
            if (Defaults[.tallyOverlayLocked]) {
                self.view.window?.acceptsMouseMovedEvents = false
                self.view.window?.ignoresMouseEvents = true
                self.view.window?.showsResizeIndicator = true
            } else {
                self.view.window?.acceptsMouseMovedEvents = true
                self.view.window?.ignoresMouseEvents = false
                self.view.window?.showsResizeIndicator = false
            }
            
            self.view.window?.alphaValue = CGFloat(Defaults[.tallyOverlayOpacity])
            
            self.tallyView.setStyle(Defaults[.tallyOverlayStyle])
            self.tallyView.setLabelVisible(visible: Defaults[.tallyOverlayShowLabel])
            
            if (Defaults[.tallyOverlayTallyAddress] < 0) {
                return
            }
            
            let packet = self.packets.first(where: { $0.key == UInt8(Defaults[.tallyOverlayTallyAddress]) })?.value
            if (packet == nil) {
                self.tallyView.setLabelText(text: "no data")
                self.tallyView.setColor(.black)
                return
            }
            
            self.tallyView.setLabelText(text: packet!.getDisplay())
            if (packet!.isTally1() && packet!.isTally2()) {
                self.tallyView.setColor(NSColor(hex: Defaults[.tallyOverlayTallyColorBoth], opacity: 1.0))
            } else if (packet!.isTally1()) {
                self.tallyView.setColor(NSColor(hex: Defaults[.tallyOverlayTallyColor1], opacity: 1.0))
            } else if (packet!.isTally2()) {
                self.tallyView.setColor(NSColor(hex: Defaults[.tallyOverlayTallyColor2], opacity: 1.0))
            } else {
                self.tallyView.setColor(.black)
            }
        }
    }
    
    @objc func onDidUpdateTally(_ notification: Notification) {
        DispatchQueue.main.sync { [weak self] in
            let packet = notification.userInfo!["packet"] as! UDMPacket
            packets[packet.getAddress()] = packet
            if (packet.getAddress() == Defaults[.tallyOverlayTallyAddress]) {
                self?.redraw()
            }
        }
    }
    
}
