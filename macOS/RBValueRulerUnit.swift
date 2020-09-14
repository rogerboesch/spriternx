
import Foundation
import Cocoa

class RBValueRulerUnit: NSView {
    
    // -------------------------------------------------------------------------
    // MARK: - Properties

    var value: Int! {
        didSet {
            self.needsDisplay = true
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        let context = NSGraphicsContext.current!.cgContext
        let _ = NSBezierPath(rect: NSMakeRect(0, 0, self.frame.width, self.frame.height))

        let ticks: CGFloat = 10
        let space = self.frame.width / ticks
        
        var tickColor:NSColor!
        var tickHeight:CGFloat = 0
        var tickWidth:CGFloat = 0
        
        for i in 0...Int(ticks) {
            if i != Int(ticks) / 2 {
                tickHeight = 6
                tickWidth = 2
                tickColor = NSColor.lightGray
            }
            else {
                tickHeight = 8
                tickWidth = 2
                tickColor = NSColor.black
            }
            
            self.drawTick(context, pointX: CGFloat(i) * space, width: tickWidth, height: tickHeight, color: tickColor)
        }
        
        if self.value != nil {
            let textRect = NSMakeRect(self.frame.width / 2 - 40, 2, 80, self.frame.height)
            
            let textTextContent = NSString(format: "%.01f", Float(self.value))
            let textStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.center
            
            let textFontAttributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: NSColor.black, NSAttributedString.Key.paragraphStyle: textStyle]
            
            let textTextHeight: CGFloat = textTextContent.boundingRect(with: NSMakeSize(textRect.width, CGFloat.infinity), options: NSString.DrawingOptions.usesLineFragmentOrigin, attributes: textFontAttributes).size.height
            let textTextRect: NSRect = NSMakeRect(textRect.minX, textRect.minY + (textRect.height - textTextHeight) / 2, textRect.width, textTextHeight)
            
            NSGraphicsContext.saveGraphicsState()
            textTextContent.draw(in: NSOffsetRect(textTextRect, 0, 0), withAttributes: textFontAttributes)
            NSGraphicsContext.restoreGraphicsState()
        }
    }

    func drawTick(_ context: CGContext, pointX: CGFloat, width: CGFloat, height: CGFloat, color: NSColor) {
        context.beginPath()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(width)
        context.setLineCap(CGLineCap.round)
        context.move(to: CGPoint(x: pointX, y: 0))
        context.addLine(to: CGPoint(x: pointX, y: height))
        context.strokePath()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Initializers
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
