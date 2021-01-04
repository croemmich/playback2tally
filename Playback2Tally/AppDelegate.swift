import Cocoa
import Defaults
import Preferences

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
        
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var overlayLockUnlockMenuItem: NSMenuItem!
    @IBOutlet weak var overlayHighShowMenuItem: NSMenuItem!
    
    var statusMenu: StatusMenuState?
    var manager: Manager!
    var observation: Defaults.Observation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        observation = Defaults.observe(keys: .tallyOverlayTallyAddress, .tallyOverlayLocked, .tallyOverlayHidden, options: []) { [weak self] in
            self?.configureOverlay()
        }
        
        statusMenu = StatusMenuState(menu)
        statusMenu?.bind(menu)
        
        configureOverlay()
    }
    
    func configureOverlay() {
        if (Defaults[.tallyOverlayTallyAddress] < 0) {
            overlayLockUnlockMenuItem.isHidden = true
            overlayHighShowMenuItem.isHidden = true
        } else {
            overlayLockUnlockMenuItem.isHidden = false
            overlayHighShowMenuItem.isHidden = false
            
            if(Defaults[.tallyOverlayLocked]) {
                overlayLockUnlockMenuItem.state = .on
            } else {
                overlayLockUnlockMenuItem.state = .off
            }
            
            if(Defaults[.tallyOverlayHidden]) {
                overlayHighShowMenuItem.state = .on
            } else {
                overlayHighShowMenuItem.state = .off
            }
        }
    }
    
    @IBAction func toggleOverlayMenuItem(_ sender: Any) {
        if let sender = sender as? NSMenuItem {
            if (sender.state == .on) {
                sender.state = .off
            } else {
                sender.state = .on
            }
            switch sender {
            case overlayLockUnlockMenuItem:
                Defaults[.tallyOverlayLocked] = (sender.state == .on)
            case overlayHighShowMenuItem:
                Defaults[.tallyOverlayHidden] = (sender.state == .on)
            default:
                break
            }
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        manager = Manager()
        manager.start()
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        manager?.stop()
        statusMenu?.unbind()
        
        return NSApplication.TerminateReply.terminateNow
    }
    
    
    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            GeneralPreferenceViewController(),
            TallyPreferenceViewController(),
            PlaybackPreferenceViewController(),
            TallyOverlayPreferenceViewController()
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

