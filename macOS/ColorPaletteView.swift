
import AppKit

class ColorPaletteView : NSView, RBObserver {
    private var _selectedIndex = 0
    private var _lines = 16
    
    // -------------------------------------------------------------------------
    // MARK: - Color access
    
    func colorWithIndex(_ index: Int) -> NSColor {
        return ProjectManager.shared.colorFromPalette(index: index)
    }

    func colorAt(column: Int, row: Int) -> NSColor {
        let index = row * _lines + column
        let color = colorWithIndex(index)
        
        return color
    }

    // -------------------------------------------------------------------------
    // MARK: - Draw
    
    override func draw(_ dirtyRect: NSRect) {
        guard ProjectManager.shared.numberOfPaletteEntries > 0 else { return }

        _lines = ProjectManager.shared.numberOfPaletteEntries / 16
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 7),
            NSAttributedString.Key.foregroundColor : NSColor.darkGray
        ]
        
        let attributesForDark = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 7),
            NSAttributedString.Key.foregroundColor : NSColor.lightGray
        ]

        let width = (self.bounds.size.width-20) / 16
        let height = (self.bounds.size.height-20) / CGFloat(_lines)
        
        var index = 0
        for y in 0..._lines-1 {
            for x in 0...15 {
                let rect = NSMakeRect(10+CGFloat(x)*width, 10+CGFloat(y)*height, width, height)
                
                let color = colorWithIndex(index)
                color.setFill()
                rect.fill()

                NSColor.black.setStroke()
                NSBezierPath(rect: rect).stroke()

                let text = "\(index)"
                
                if color.isDark {
                    text.draw(in: rect.moveDown(6), withAttributes: attributesForDark)
                }
                else {
                    text.draw(in: rect.moveDown(6), withAttributes: attributes)
                }
                
                index += 1
            }
        }
        
        // Mark selected color
        var y = _selectedIndex / _lines
        var x = _selectedIndex - y * _lines
        
        var rect = NSMakeRect(10+CGFloat(x)*width, 10+CGFloat(y)*height, width, height)
        
        NSColor.white.setStroke()
        NSBezierPath(rect: rect).stroke()
        NSBezierPath(rect: rect.insetBy(dx: 1, dy: 1)).stroke()

        NSColor.black.setStroke()
        NSBezierPath(rect: rect.insetBy(dx: -1, dy: -1)).stroke()

        // Mark transparent color
        y = ProjectManager.shared.paletteTransparentColorIndex / _lines
        x = ProjectManager.shared.paletteTransparentColorIndex - y * _lines
        
        rect = NSMakeRect(10+CGFloat(x)*width, 10+CGFloat(y)*height, width, height)
        
        NSColor.gray.setStroke()
        NSBezierPath(rect: rect).stroke()
        NSBezierPath(rect: rect.insetBy(dx: 1, dy: 1)).stroke()

        NSColor.black.setStroke()
        NSBezierPath(rect: rect.insetBy(dx: -1, dy: -1)).stroke()

        NSColor.black.setStroke()
        NSBezierPath(rect: self.bounds.insetBy(dx: 1, dy: 1)).stroke()
        NSColor.darkGray.setStroke()
        NSBezierPath(rect: self.bounds.insetBy(dx: 2, dy: 2)).stroke()
    }

    // -------------------------------------------------------------------------
    // MARK: - Action

    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        guard ProjectManager.shared.numberOfPaletteEntries > 0 else { return }

        let location: CGPoint = gestureRecognizer.location(in: self)

        let width = (self.bounds.size.width-20) / 16
        let height = (self.bounds.size.height-20) / CGFloat(_lines)

        let x = Int(location.x-10) / Int(width)
        let y = Int(location.y-10) / Int(height)
        
        _selectedIndex = y * _lines + x

        self.needsDisplay = true
        
        ProjectManager.shared.paletteColorIndex = _selectedIndex
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Observer

    func onReceive(action: ObserverAction, from sender: Any?) {
        switch action {
        case .paletteChanged:
            needsDisplay = true
        case .transColorChanged:
            needsDisplay = true
        case .currentProjectChanged:
            needsDisplay = true
        default:
            break
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Initialisation
    
    override var isFlipped: Bool {
        return true
    }
    
    private func initView() {
        var gestureRecognizers = self.gestureRecognizers
        
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        gestureRecognizers.insert(clickGesture, at: 0)
        self.gestureRecognizers = gestureRecognizers

        register(for: .currentProjectChanged, observer: self)
        register(for: .transColorChanged, observer: self)
        register(for: .paletteChanged, observer: self)
    }

    override init(frame: NSRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initView()
    }
    
}
