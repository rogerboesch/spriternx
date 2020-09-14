
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var _window: NSWindow!
    private var _menu: NSMenu!
    private var _toolbar: RBNSToolbar!

    private var _console: ConsolePanel!

    private var _liveSegmentItem: NSToolbarItem?
    private var _consolePosition: CGPoint?

    // -------------------------------------------------------------------------
    // MARK: - Properties
    
    override var description: String {
        get {
            let className = type(of: self)
            return "\(className)-\(self.hash)"
        }
    }

    var window: NSWindow {
        get {
            return _window
        }
        set(value) {
            _window = value
        }
    }
    
    var menu: NSMenu {
        get {
            return _menu
        }
        set(value) {
            _menu = value
        }
    }
    
    var toolbar: RBNSToolbar {
        get {
            return _toolbar
        }
        set(value) {
            _toolbar = value
        }
    }
    
    var console: ConsolePanel {
        get {
            return _console
        }
        set(value) {
            _console = value
        }
    }

    var applicationName: String {
        get {
            if let key = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") {
                if let nameOfBundle = key as? String {
                    return nameOfBundle
                }
            }
            
            return "Unknown"
        }
    }
    
    var applicationID: String {
        get {
            if let key = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") {
                if let idOfBundle = key as? String {
                    return idOfBundle
                }
            }
            
            return "Unknown"
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Application life cycle
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        RBLog.severity = .debug

        createUI()

        // Load project
        ProjectManager.shared.createProject("Demo")
        ProjectManager.shared.loadProject("Demo")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) { }
    
    static let shared : AppDelegate = {
        let instance = NSApplication.shared.delegate as? AppDelegate
        return instance!
    }()

}

