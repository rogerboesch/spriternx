
import AppKit

class RBPanelWindow : NSPanel, NSWindowDelegate {
    private var _isHidden = false

    // -------------------------------------------------------------------------
    // MARK: - Properties

    var isHidden: Bool {
        get {
            return _isHidden
        }
        set(value) {
            _isHidden = value
            
            if value {
                self.orderOut(nil)
            }
            else {
                self.makeKeyAndOrderFront(nil)
            }
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Overrides

    func save() {}
    
    // -------------------------------------------------------------------------
    // MARK: - Window delegate

    func windowWillClose(_ notification: Notification) {
        save()
    }

    // -------------------------------------------------------------------------
    // MARK: - Initialisation

    init(contentRect: NSRect) {
        let styleMask: NSWindow.StyleMask = [NSWindow.StyleMask.titled, NSWindow.StyleMask.hudWindow, NSWindow.StyleMask.utilityWindow]

        super.init(contentRect: contentRect, styleMask: styleMask, backing: NSWindow.BackingStoreType.buffered, defer: true)
        
        self.delegate = self
    }

}
