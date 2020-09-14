
import AppKit

var consoleInstance: ConsolePanel?

class ConsolePanel : RBPanelWindow, RBLogger, NSTextFieldDelegate {
    private var maxBufferSize = 8
    private var _buffer: [String] = []

    private var _scrollView: NSScrollView!
    private var _textView: NSTextView!
    private var _inputView: NSTextField!

    // -------------------------------------------------------------------------
    // MARK: - Properties
    
    override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set(value) {
            super.isHidden = value
            
            if super.isHidden {
                RBLog.logger = nil
            }
            else {
                RBLog.logger = self
                _inputView.becomeFirstResponder()
            }
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Write to console

    private func print(_ message: String) {
        _buffer.append(message)
        if _buffer.count > maxBufferSize {
            _buffer.remove(at: 0)
        }
        
        var output = ""
        for entry in _buffer {
            output += entry
        }
        
        DispatchQueue.main.async {
            self._textView.string = output
        }
    }

    func print(_ message: String, terminate: Bool) {
        if self.isHidden {
            return
        }
        
        if terminate {
            print(message + "\n")
        }
        else {
            print(message)
        }
    }

    func clear() {
        _buffer.removeAll()
        
        DispatchQueue.main.async {
            self._textView.string = ""
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Scripting support

    private func executeScript() {
    }

    // -------------------------------------------------------------------------
    // MARK: - NSTextField delegate

    func controlTextDidEndEditing(_ aNotification : Notification) {
        if let code = aNotification.userInfo?["NSTextMovement"] as? Int {
            if code == NSReturnTextMovement {
                executeScript()
            }
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Initialisation
    
    override init(contentRect: NSRect) {
        super.init(contentRect: contentRect)
        
        self.title = "Console"

        var rect = self.contentView!.bounds
        rect.origin.y = 30
        rect.size.height -= 30

        _scrollView = NSScrollView(frame: rect)
        self.contentView?.addSubview(_scrollView)

        _textView = NSTextView(frame: rect)
        _textView.drawsBackground = false
        _textView.font = NSFont(name: "Andale Mono", size: 12)
        _textView.textColor = NSColor.green
        _textView.isEditable = false
        _textView.alignment = .left
        _scrollView.addSubview(_textView)
        _scrollView.documentView = _textView

        rect = self.contentView!.bounds
        rect.size.height = 30

        _inputView = NSTextField(frame: rect)
        _inputView.alignment = .left
        _inputView.isEditable = true
        _inputView.font = NSFont(name: "Andale Mono", size: 12)
        _inputView.delegate = self
        self.contentView?.addSubview(_inputView)

        consoleInstance = self
    }
    
    static var shared : ConsolePanel {
        get {
            return consoleInstance!
        }
    }
}

