
import Cocoa

class RBView : NSView {
    private var _blackView: NSView?
    
    // -------------------------------------------------------------------------
    // MARK: - Properties

    var isViewDisabled: Bool {
        get {
            return _blackView == nil ? false : true
        }
        set(value) {
            if value {
                _blackView = NSTextField(labelWithString: "")
                _blackView!.frame = NSMakeRect(0, 0, 1000, 1500) // HACK
                _blackView!.wantsLayer = true
                _blackView!.layer?.backgroundColor = OSColor(hex: "#00000066").cgColor
                self.addSubview(_blackView!)
            }
            else {
                _blackView?.removeFromSuperview()
                _blackView = nil
            }
        }
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        
        if _blackView != nil {
            _blackView!.frame = self.bounds
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Initialisation
    
    private func initView() {
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


