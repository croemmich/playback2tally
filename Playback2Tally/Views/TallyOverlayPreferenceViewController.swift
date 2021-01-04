import Cocoa
import Defaults
import Preferences

final class TallyOverlayPreferenceViewController: NSViewController, PreferencePane, NSTextFieldDelegate {
    let preferencePaneIdentifier = Preferences.PaneIdentifier.tally
    let preferencePaneTitle = "Overlay"

    override var nibName: NSNib.Name? { "TallyOverlayPreferenceViewController" }

    @IBOutlet weak var udmServerPortField: NSTextField!
    @IBOutlet weak var udmServerProtoPopUp: NSPopUpButton!
    
    @IBOutlet weak var overlayAddressPopUp: NSPopUpButton!
    @IBOutlet weak var overlayStylePopUp: NSPopUpButton!
    @IBOutlet weak var overlayLabelCheck: NSButton!
    @IBOutlet weak var overlayOpacitySlider: NSSlider!
    @IBOutlet weak var overlayColor1Well: NSColorWell!
    @IBOutlet weak var overlayColor2Well: NSColorWell!
    @IBOutlet weak var overlayColorBothWell: NSColorWell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildUdmAddressMenu(overlayAddressPopUp.menu!)
        overlayAddressPopUp.selectItem(withTag: Defaults[.tallyOverlayTallyAddress])
        
        udmServerPortField.integerValue = Defaults[.udmServerPort]
        udmServerPortField.formatter = portNumberValidator()
        udmServerProtoPopUp.selectItem(withTitle: (Defaults[.udmServerProto].rawValue))
        
        overlayStylePopUp.selectItem(withTitle: Defaults[.tallyOverlayType].rawValue)
        
        if (Defaults[.tallyOverlayShowLabel]) {
            overlayLabelCheck.state = .on
        } else {
            overlayLabelCheck.state = .off
        }
        
        overlayOpacitySlider.integerValue = Int(Defaults[.tallyOverlayOpacity] * 100)
                
        overlayColor1Well.color = NSColor(hex: Defaults[.tallyOverlayTallyColor1], opacity: 1)
        overlayColor2Well.color = NSColor(hex: Defaults[.tallyOverlayTallyColor2], opacity: 1)
        overlayColorBothWell.color = NSColor(hex: Defaults[.tallyOverlayTallyColorBoth], opacity: 1)
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
            case udmServerPortField:
                validateAndSetIntField(field: udmServerPortField, key: Defaults.Keys.udmServerPort)
            default:
                break
            }
        }
    }
    
    @IBAction func opacityChanged(_ sender: Any) {
        if let sender = sender as? NSSlider {
            Defaults[.tallyOverlayOpacity] = sender.floatValue / 100
        }
    }
    
    @IBAction func checkSelected(_ sender: Any) {
        if let sender = sender as? NSButton {
            switch sender {
            case overlayLabelCheck:
                Defaults[.tallyOverlayShowLabel] = (sender.state == .on)
            default:
                break
            }
        }
    }
    
    @IBAction func popupButtonSelected(_ sender: Any) {
        if let sender = sender as? NSPopUpButton {
            switch sender {
            case overlayAddressPopUp:
                Defaults[.tallyOverlayTallyAddress] = sender.selectedTag()
            case udmServerProtoPopUp:
                Defaults[.udmServerProto] = UdmProtocol.init(rawValue: sender.selectedItem!.title)!
            case overlayStylePopUp:
                Defaults[.tallyOverlayType] = OverlayType.init(rawValue: sender.selectedItem!.title)!
            default:
                break
            }
        }
    }
    
    @IBAction func colorSelected(_ sender: Any) {
        if let sender = sender as? NSColorWell {
            switch sender {
            case overlayColor1Well:
                Defaults[.tallyOverlayTallyColor1] = sender.color.hexString
            case overlayColor2Well:
                Defaults[.tallyOverlayTallyColor2] = sender.color.hexString
            case overlayColorBothWell:
                Defaults[.tallyOverlayTallyColorBoth] = sender.color.hexString
            default:
                break
            }
        }
    }
    
}
