
import AppKit

class RBTextLabel : NSView {
    private var _text = ""
    
    func setText(_ text: String) {
        _text = text
        self.needsDisplay = true
    }
    
    override var isFlipped: Bool {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor : NSColor.black
        ]

        let rect = self.bounds

        _text.draw(in: rect.moveDown(8), withAttributes: attributes)
    }

}
