import Cocoa
import Preferences
import SwiftyUserDefaults

final class PlaybackPreferenceViewController: NSViewController, PreferencePane, NSTextFieldDelegate {
    let preferencePaneIdentifier = Preferences.PaneIdentifier.playback
    let preferencePaneTitle = "Playback"

    override var nibName: NSNib.Name? { "PlaybackPreferenceViewController" }

    @IBOutlet weak var playbackType: NSPopUpButton!
    @IBOutlet weak var mittiPrefrences: NSView!
    
    @IBOutlet weak var mittiFeedbackPortField: NSTextField!
    @IBOutlet weak var mittiHostField: NSTextField!
    @IBOutlet weak var mittiPortField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the playback varient
        playbackType.menu!.removeAllItems()
        for varient in PlaybackVariant.allCases {
            playbackType.addItem(withTitle: varient.rawValue)
        }
        playbackType.selectItem(withTitle: Defaults.playbackVariant.rawValue)
        selectPrefrenceView()
        
        // set up mitti fields
        mittiFeedbackPortField.integerValue = Defaults.mittiFeedbackPort
        mittiFeedbackPortField.formatter = portNumberValidator()
        
        mittiHostField.stringValue = Defaults.mittiHost
        
        mittiPortField.integerValue = Defaults.mittiPort
        mittiPortField.formatter = portNumberValidator()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if let sender = obj.object as? NSTextField {
            switch sender {
            case mittiFeedbackPortField:
                validateAndSetIntField(field: mittiFeedbackPortField, key: Defaults.keyStore.mittiFeedbackPort)
            case mittiHostField:
                validateAndSetStringField(field: mittiHostField, key: Defaults.keyStore.mittiHost, validator: notEmptyStringValidator())
            case mittiPortField:
                validateAndSetIntField(field: mittiPortField, key: Defaults.keyStore.mittiPort)
            default:
                break
            }
        }
    }
    
    @IBAction func onPlaybackTypeChanged(_ sender: Any) {
        if let sender = sender as? NSPopUpButton {
            Defaults.playbackVariant = PlaybackVariant.init(rawValue: sender.selectedItem!.title)!
            selectPrefrenceView()
        }
    }
    
    func selectPrefrenceView() {
        switch Defaults.playbackVariant {
        case .mitti:
            mittiPrefrences.isHidden = false
        }
    }
    
}
