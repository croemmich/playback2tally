import Cocoa
import Preferences

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
        
    @IBOutlet weak var menu: NSMenu!
    
    var statusMenu: StatusMenuState?
    var manager: Manager!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        statusMenu = StatusMenuState(menu)
        statusMenu?.bind(menu)
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

