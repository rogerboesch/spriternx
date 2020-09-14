
import Cocoa

class SpriteView : RBView, RBObserver {
    private var spriteSize: CGFloat = 16;
    private var scale: CGFloat = 1;
    var _data: [Int] = []

    var number = 0
    
    // -------------------------------------------------------------------------
    // MARK: - Properties
    
    override var description: String {
        get {
            let className = type(of: self)
            return "\(className)-\(self.hash)"
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    
    @objc func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
    }

    // -------------------------------------------------------------------------
    // MARK: - Draw

    private func drawData() {
        guard _data.count > 0 else { return }

        let width: CGFloat = spriteSize * scale
        let height: CGFloat = spriteSize * scale
        let x = (self.bounds.size.width-width)/2
        let y = (self.bounds.size.height-height)/2

        // TODO: Specify transparent color
        for v in 0...Int(spriteSize-1) {
            for h in 0...Int(spriteSize-1) {
                let pos = v*Int(spriteSize)+h
                let index = _data[pos]
                
                if index >= 0 {
                    let color = ProjectManager.shared.colorFromPalette(index: index)
                    let rect = NSRect.make(x+CGFloat(h)*scale, y+CGFloat(v)*scale, scale, scale)
                    
                    if index == ProjectManager.shared.paletteTransparentColorIndex && ProjectManager.shared.showTransparentColor {
                        color.setFill()
                        rect.fill()
                    }
                    else if index != ProjectManager.shared.paletteTransparentColorIndex {
                        color.setFill()
                        rect.fill()
                    }
                }
            }
        }
    }

    private func drawGrid() {
        let width: CGFloat = spriteSize * scale
        let height: CGFloat = spriteSize * scale
        let x = (self.bounds.size.width-width)/2
        let y = (self.bounds.size.height-height)/2
        
        NSColor.lightGray.setStroke()
        
        var flag = true
        let count = width / scale
        for v in 0..<Int(count) {
            for h in 0..<Int(count) {
                if flag {
                    NSColor.white.setFill()
                }
                else {
                    NSColor.lightGray.setFill()
                }
                
                NSRect.make(x+CGFloat(h)*scale, y+CGFloat(v)*scale, scale, scale).fill()

                flag = !flag
            }
            
            flag = !flag
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        drawGrid()
        drawData()
    }

    // -------------------------------------------------------------------------
    // MARK: - Observer

    func updateData(_ data: [Int]) {
        _data = data
        needsDisplay = true
    }
    
    func onReceive(action: ObserverAction, from sender: Any?) {
        switch action {
        case .currentSpriteChanged:
            if ProjectManager.shared.currentSprite == number {
                needsDisplay = true
            }
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
        self.wantsLayer = true
        self.layer?.backgroundColor = Settings.UI.SpriteView.background.cgColor
        
        // Gestures
        var gestureRecognizers = self.gestureRecognizers
        
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        gestureRecognizers.insert(clickGesture, at: 0)
        self.gestureRecognizers = gestureRecognizers

        self.register(for: .currentSpriteChanged, observer: self)
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



