import Cocoa
import Defaults
import Preferences

final class TallyOverlayView: NSView {
    
    var style : OverlayStyle = .box
    var color : NSColor = .black
    
    @IBOutlet weak var label: NSTextField!
    
    public func setStyle(_ style: OverlayStyle) {
        self.style = style
        redraw()
        setNeedsDisplay(.infinite)
    }
    
    public func setColor(_ color: NSColor) {
        self.color = color
        redraw()
    }
    
    public func setLabelText(text: String) {
        label.stringValue = text
    }
    
    public func setLabelVisible(visible: Bool) {
        label.isHidden = !visible
    }
    
    private func redraw() {
        switch style {
        case .border:
            self.window?.backgroundColor = .clear
        case .box:
            self.window?.backgroundColor = color
        }
        label.backgroundColor = color
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        switch style {
        case .border:
            let border:NSBezierPath = NSBezierPath(rect: bounds)
            color.set()
            border.lineWidth = 10
            border.stroke()
        case .box:
            break
        }
    }
    
}
