
import AppKit

typealias PatternValueChangeCallback = (RBPatternView) -> ()

class RBPatternView: NSView {
    private var _maxPattern: Int = 1
    private var _pattern: Int = 1
    private var _number: Int = 1

    var callback: PatternValueChangeCallback?
    
    // -------------------------------------------------------------------------
    // MARK: - Properties
    
    var number: Int {
        get {
            return _number
        }
        set(value) {
            _number = value
        }
    }
    
    var patterns: Int {
        get {
            return _maxPattern
        }
        set(value) {
            _maxPattern = value
        }
    }
    
    var pattern: Int {
        get {
            return _pattern
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        _pattern += 1
        if _pattern > _maxPattern {
            _pattern = 1
        }
        
        self.needsDisplay = true
        
        if callback != nil {
            callback!(self)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        Settings.UI.gray.setFill()
        self.bounds.fill()

        let rect = self.bounds.insetBy(dx: 5, dy: 5)

        if let image = OSImage.getImage(named: "pattern-\(_pattern)") {
            image.draw(in: rect)
        }

        NSColor.black.setStroke()
        NSBezierPath(rect: rect).stroke()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Initialisation
    
    private func initView() {
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = self.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        self.gestureRecognizers = gestureRecognizers
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initView()
    }
    
}



