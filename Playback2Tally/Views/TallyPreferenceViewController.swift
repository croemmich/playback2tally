import Cocoa
import Defaults
import Preferences

final class TallyPreferenceViewController: NSViewController, PreferencePane, NSTextFieldDelegate {
    let preferencePaneIdentifier = Preferences.PaneIdentifier.tally
    let preferencePaneTitle = "Tally"

    override var nibName: NSNib.Name? { "TallyPreferenceViewController" }

    @IBOutlet weak var udmHostField: NSTextField!
    @IBOutlet weak var udmPortField: NSTextField!
    @IBOutlet weak var udmAddressCueName: NSPopUpButton!
    @IBOutlet weak var udmAddressTotalTime: NSPopUpButton!
    @IBOutlet weak var udmAddressTimeLeft: NSPopUpButton!
    @IBOutlet weak var udmAddressTimeElapsed: NSPopUpButton!
    @IBOutlet weak var udmAddressPreviousCueName: NSPopUpButton!
    @IBOutlet weak var udmAddressNextCueName: NSPopUpButton!
    
    var addressPopUps : Array<NSPopUpButton>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        udmHostField.stringValue = Defaults[.udmHost]
        
        udmPortField.integerValue = Defaults[.udmPort]
        udmPortField.formatter = portNumberValidator()
  
        addressPopUps = [udmAddressCueName, udmAddressTotalTime, udmAddressTimeLeft, udmAddressTimeElapsed, udmAddressPreviousCueName, udmAddressNextCueName]
        for popup in addressPopUps! {
            buildUdmAddressMenu(popup.menu!)
            popup.autoenablesItems = false
        }
        udmAddressCueName.selectItem(withTag: Defaults[.udmAddressCueName])
        udmAddressTotalTime.selectItem(withTag: Defaults[.udmAddressTimeTotal])
        udmAddressTimeLeft.selectItem(withTag: Defaults[.udmAddressTimeLeft])
        udmAddressTimeElapsed.selectItem(withTag: Defaults[.udmAddressTimeElapsed])
        udmAddressPreviousCueName.selectItem(withTag: Defaults[.udmAddressPreviousCueName])
        udmAddressNextCueName.selectItem(withTag: Defaults[.udmAddressNextCueName])
        
        calculateEnabledAddressEntries()
    }
    
    func buildUdmAddressMenu(_ menu: NSMenu) {
        menu.removeAllItems()
        
        let disabled = NSMenuItem()
        disabled.title = "Off"
        disabled.tag = -1
        menu.addItem(disabled)
        
        for idx in 0...126 {
            let item = NSMenuItem()
            item.title = String(idx)
            item.tag = idx
            menu.addItem(item)
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if let sender = obj.object as? NSTextField {
            switch sender {
            case udmHostField:
                validateAndSetStringField(field: udmHostField, key: Defaults.Keys.udmHost, validator: notEmptyStringValidator())
            case udmPortField:
                validateAndSetIntField(field: udmPortField, key: Defaults.Keys.udmPort)
            default:
                break
            }
        }
    }
    
    @IBAction func popupButtonSelected(_ sender: Any) {
        if let sender = sender as? NSPopUpButton {
            switch sender {
            case udmAddressCueName:
                Defaults[.udmAddressCueName] = sender.selectedTag()
            case udmAddressTotalTime:
                Defaults[.udmAddressTimeTotal] = sender.selectedTag()
            case udmAddressTimeLeft:
                Defaults[.udmAddressTimeLeft] = sender.selectedTag()
            case udmAddressTimeElapsed:
                Defaults[.udmAddressTimeElapsed] = sender.selectedTag()
            case udmAddressPreviousCueName:
                Defaults[.udmAddressPreviousCueName] = sender.selectedTag()
            case udmAddressNextCueName:
                Defaults[.udmAddressNextCueName] = sender.selectedTag()
            default:
                break
            }
            
            calculateEnabledAddressEntries()
        }
    }
    
    func calculateEnabledAddressEntries() {
        for popup in addressPopUps! {
            var selectedOptions : Array<Int> = []
            for other in addressPopUps! {
                if (popup == other) {
                    continue
                }
                selectedOptions.append(other.selectedTag())
            }
            for menuItem in popup.menu!.items {
                if (menuItem.tag == -1) {
                    continue
                }
                if (selectedOptions.contains(menuItem.tag)) {
                    menuItem.isEnabled = false
                } else {
                    menuItem.isEnabled = true
                }
            }
        }
    }
    
}
