import Cocoa
import Preferences
import SwiftyUserDefaults

extension PreferencePane {
    
    typealias StringValidator = (String) -> (valid: Bool, message: String?)
    
    func validateAndSetStringField(field: NSTextField, key: DefaultsKey<String>, validator: StringValidator? = nil) {
        if (field.stringValue == "") {
            Defaults.remove(key)
            field.stringValue = Defaults[key: key]
        }
        
        if (validator != nil) {
            let result = validator!(field.stringValue)
            if (!result.valid) {
                displayError(field: field, message: result.message)
                return
            } else {
                clearError(field: field)
            }
        }
        
        Defaults[key: key] = field.stringValue
    }
    
    typealias IntValidator = (Int) -> (valid: Bool, message: String?)
    
    func validateAndSetIntField(field: NSTextField, key: DefaultsKey<Int>, validator: IntValidator? = nil) {
        if (field.integerValue == 0) {
            Defaults.remove(key)
            field.integerValue = Defaults[key: key]
        }
        
        if (validator != nil) {
            let result = validator!(field.integerValue)
            if (!result.valid) {
                displayError(field: field, message: result.message)
                return
            } else {
                clearError(field: field)
            }
        }
        
        Defaults[key: key] = field.integerValue
    }
    
    func displayError(field: NSView, message: String?) {
        field.superview?.wantsLayer = true
        field.superview?.layer?.masksToBounds = false
        field.wantsLayer = true
        field.layer?.masksToBounds = false
        
        let image = NSImageView()
        image.image = NSImage.init(named: NSImage.stopProgressFreestandingTemplateName)
        image.frame = NSRect(x: field.bounds.width - 20, y: 0, width: 20, height: 20)
        image.contentTintColor = .systemRed
        image.toolTip = message
        image.allowsExpansionToolTips = true
        field.addSubview(image)
    }
    
    func clearError(field: NSTextField) {
        field.subviews.removeAll()
    }
    
    func portNumberValidator() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.hasThousandSeparators = false
        formatter.minimum = 1
        formatter.maximum = 65535
        
        return formatter
    }
    
    func notEmptyStringValidator() -> StringValidator {
        return {(value) -> (valid: Bool, message: String?) in
            if (value == "") {
                return (false, "cannot be empty")
            }
            return (true, nil)
        }
    }    
}
