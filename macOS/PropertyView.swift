
import Cocoa

class PropertyView : NSView, RBObserver {
    private var _colorView: ColorPaletteView!

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

    func onReceive(action: ObserverAction, from sender: Any?) {
        switch action {
        case .paletteChanged:
            self.needsLayout = true
        default:
            break
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - View life cycle

    private func updateUI() {
        var height: CGFloat = self.bounds.size.width
        if ProjectManager.shared.numberOfPaletteEntries > 256 {
            height = height * 2
        }
        
        _colorView.frame = NSMakeRect(0, 0, self.bounds.size.width, height)
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        updateUI()
    }

    override func layout() {
        super.layout()
        updateUI()
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Initialisation
    
    private func initView() {
        self.wantsLayer = true
        self.layer?.backgroundColor = Settings.UI.PropertyView.background.cgColor

        self.register(for: .paletteChanged, observer: self)

        _colorView = ColorPaletteView(frame: NSRect.zero)
        self.addSubview(_colorView)
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




