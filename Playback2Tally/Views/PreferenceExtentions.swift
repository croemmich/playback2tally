import Cocoa
import Defaults
import Preferences

extension PreferencePane {
    
    typealias StringValidator = (String) -> (valid: Bool, message: String?)
    
    func validateAndSetStringField(field: NSTextField, key: Defaults.Key<String>, validator: StringValidator? = nil) {
        if (field.stringValue == "") {
            Defaults.reset(key)
            field.stringValue = Defaults[key]
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
        
        Defaults[key] = field.stringValue
    }
    
    typealias IntValidator = (Int) -> (valid: Bool, message: String?)
    
    func validateAndSetIntField(field: NSTextField, key: Defaults.Key<Int>, validator: IntValidator? = nil) {
        if (field.integerValue == 0) {
            Defaults.reset(key)
            field.integerValue = Defaults[key]
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
        
        Defaults[key] = field.integerValue
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
    
    func integerValidatorBetween(_ min: Int, _ max: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.hasThousandSeparators = false
        formatter.minimum = NSNumber(value: min)
        formatter.maximum = NSNumber(value: max)
        
        return formatter
    }
    
    func portNumberValidator() -> NumberFormatter {
        return integerValidatorBetween(1, 65535)
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
