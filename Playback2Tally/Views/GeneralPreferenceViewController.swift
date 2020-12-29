import Cocoa
import LaunchAtLogin
import Preferences

final class GeneralPreferenceViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = Preferences.PaneIdentifier.general
    let preferencePaneTitle = "General"

    override var nibName: NSNib.Name? { "GeneralPreferenceViewController" }

    @objc dynamic var launchAtLogin = LaunchAtLogin.kvo
    
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var copyrightLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.stringValue = "Version: " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        copyrightLabel.stringValue = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as! String
    }
}
