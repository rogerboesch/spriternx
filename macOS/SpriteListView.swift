
import Cocoa

class SpriteListView : NSView, RBObserver {
    private var _listOfSprites: [SpriteView] = []
    
    // -------------------------------------------------------------------------
    // MARK: - Properties
    
    override var description: String {
        get {
            let className = type(of: self)
            return "\(className)-\(self.hash)"
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Observer
    
    private func updateIcon(number: Int) {
        let data = ProjectManager.shared.loadSpriteData(number: number)
        _listOfSprites[number-1].updateData(data)
    }
    
    private func updateAllIcons() {
        for i in 1...16 {
            updateIcon(number: i)
        }
    }

    func onReceive(action: ObserverAction, from sender: Any?) {
        switch action {
        case .currentProjectChanged:
            updateAllIcons()
            self.needsLayout = true
        case .currentSpriteChanged:
            updateIcon(number: ProjectManager.shared.currentSprite)
            self.needsLayout = true
        default:
            break
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - View life cycle

    override func resizeSubviews(withOldSize oldSize: NSSize) {
    }

    override func layout() {
        super.layout()
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Initialisation
    
    private func initView() {
        self.wantsLayer = true
        self.layer?.backgroundColor = Settings.UI.PropertyView.background.cgColor

        for i in 0...15 {
            let rect = NSRect.make(10, CGFloat(10+(i*20)), 16, 16)
            let spriteView = SpriteView(frame: rect)
            spriteView.number = i + 1
            
            self.addSubview(spriteView)
            _listOfSprites.append(spriteView)
        }
        
        self.register(for: .currentProjectChanged, observer: self)
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
    
    // -------------------------------------------------------------------------
    
}




