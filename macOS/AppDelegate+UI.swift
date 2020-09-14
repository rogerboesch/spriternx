
import Cocoa

extension Settings {
    
    struct File {
        static let ext = ".sprites.app"
    }
    
}

extension NSMenu {

    func selectChildWithTag(_ tag: Int, _ flag: Bool) {
        for child in self.items {
            if child.tag == tag {
                child.state = flag ? .on : .off
            }
        }
    }

}

extension AppDelegate: NSSplitViewDelegate, NSWindowDelegate, RBObserver {

    // -------------------------------------------------------------------------
    // MARK: - UI Helper

    private func updateSpriteNumber() {
        let number = ProjectManager.shared.currentSprite
        let total = ProjectManager.shared.numberOfSprites
        let str = "\(number) of \(total)"

        let segment = self.toolbar.segmentForItem("spriteno")
        segment?.setLabel(str, forSegment: 0)
    }

    // -------------------------------------------------------------------------
    // MARK: - Observer

    func onReceive(action: ObserverAction, from sender: Any?) {
        switch action {
        case .currentProjectChanged:
            self.window.title = "spriterNX | ZX Spectrum Next Edition".localized + " - " + ProjectManager.shared.nameOfProject
            self.toolbar.colorForItem("transColor", color: ProjectManager.shared.transparentColor)
            self.toolbar.colorForItem("color", color: ProjectManager.shared.color)
            updateSpriteNumber()
        case .currentSpriteChanged:
            updateSpriteNumber()
        case .colorChanged:
            let color = ProjectManager.shared.color
            self.toolbar.colorForItem("color", color: color)
        case .transColorChanged:
            self.toolbar.colorForItem("transColor", color: ProjectManager.shared.transparentColor)
        case .paletteChanged:
            self.toolbar.colorForItem("transColor", color: ProjectManager.shared.transparentColor)
            self.toolbar.colorForItem("color", color: ProjectManager.shared.color)
        default:
            break
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Actions

    @objc func toggleConsole(_ item: NSMenuItem) {
        self.console.isHidden = !self.console.isHidden
        item.state = self.console.isHidden ? .off : .on
    }
    
    @objc func save(_ item: NSMenuItem) {
        notify(with: .dataMustBeSaved, sender: self)
    }
    
    @objc func importImage(_ item: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["png","jpg","bmp","tga"]
        
        let clicked = panel.runModal()

        if clicked == NSApplication.ModalResponse.OK {
            if let url = panel.url {
                ProjectManager.shared.importImage(path: url.path)
            }
        }
    }
    
    @objc func importSPR(_ item: NSMenuItem) {
    }

    @objc func exportSPR(_ item: NSMenuItem) {
    }

    @objc func addSprite(_ item: NSMenuItem) {
        ProjectManager.shared.addNewSprite(example: false)
    }
    
    @objc func addExampleSprite(_ item: NSMenuItem) {
        ProjectManager.shared.addNewSprite(example: true)
    }

    // -------------------------------------------------------------------------
    // MARK: - Create Toolbar
    
    private func createToolbar() {
        self.toolbar = RBNSToolbar(name: "myToolbar")

        self.toolbar.addItem(name: "prev", title: "Previous", icon: OSImage.getImage(named: "EndLArrow")!, { (segment, value) in
            ProjectManager.shared.prevSprite()
        })
        
        self.toolbar.addSegment(name: "spriteno", title: "Sprite", width: 60, ["0 of 0"], [])
        
        self.toolbar.addItem(name: "next", title: "Next", icon: OSImage.getImage(named: "EndRArrow")!, { (segment, value) in
            ProjectManager.shared.nextSprite()
        })
        
        self.toolbar.addSpace(10)

        self.toolbar.addSegment(name: "size", title:"Sprite size", width: 50, ["16x16"], [], { (segment, value) in
            //switch segment {
            //case 0:
            //    ProjectManager.shared.size = 8
            //case 1:
            //    ProjectManager.shared.size = 16
            //case 2:
            //    ProjectManager.shared.size = 32
            //case 3:
            //    ProjectManager.shared.size = 64
            //default:
            //    ProjectManager.shared.size = 16
            //}
        })
        
        var (segment, _) = self.toolbar.addSegment(name: "actLayer", multiple: false, title: "Active Layer", width: 20, ["", "", ""], ["Layer1", "Layer2", "Layer3"])
        segment.isEnabled = false

        (segment, _) = self.toolbar.addSegment(name: "visLayer", multiple: true, title: "Visible Layers", width: 20, ["1", "2", "3"], ["Layer1", "Layer2", "Layer3"])
        segment.isEnabled = false

        self.toolbar.addSpace(10)

        self.toolbar.addColorWell(name: "color", title: "Color", width: 50)
        self.toolbar.addColorWell(name: "transColor", title: "Transparency", width: 50)
        self.toolbar.addItemToggle(name: "transToggle", title: "Show") { (sender, value) in
            ProjectManager.shared.showTransparentColor = !ProjectManager.shared.showTransparentColor
        }
        
        self.toolbar.addSpace(10)

        let icons2 = ["BrushTool", "DeleteCursor", "ColorPicker"]
        self.toolbar.addSegment(name: "pencil", title:"Pencil Mode", width: 40, ["", "", ""], icons2, { (segment, value) in
            switch segment {
            case 0:
                ProjectManager.shared.pencilMode = 1
            case 1:
                ProjectManager.shared.pencilMode = 2
            case 2:
                ProjectManager.shared.pencilMode = 3
                
            default:
                ProjectManager.shared.pencilMode = 1
            }
        })
        
        self.toolbar.addSegment(name: "mirror", multiple: true, title: "Mirror", width: 30, ["", ""], ["MirrorH", "MirrorV"], { (segment, value) in
            switch segment {
            case 0:
                ProjectManager.shared.toggleMirrorH()
            case 1:
                ProjectManager.shared.toggleMirrorV()
            default:
                break
            }
        })
        
        self.toolbar.addSpace(10)
        
        self.toolbar.addSegment(name: "zoom", title:"Zoom", width: 40, ["10x", "20x", "30x"], [], { (segment, value) in
            switch segment {
            case 0:
                ProjectManager.shared.zoom = 10
            case 1:
                ProjectManager.shared.zoom = 20
            case 2:
                ProjectManager.shared.zoom = 30
            default:
                ProjectManager.shared.zoom = 20
            }
        })
        
        self.toolbar.setSegmentFont("zoom", font: NSFont.boldSystemFont(ofSize: 11))
        self.toolbar.selectSegmentItem("zoom", item: 1)
        ProjectManager.shared.zoom = 20
        
        self.toolbar.setSegmentFont("size", font: NSFont.boldSystemFont(ofSize: 11))
        self.toolbar.selectSegmentItem("size", item: 0)
        ProjectManager.shared.size = 16
        
        self.window.toolbar = self.toolbar
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Create Menu
    
    private func createMiniMenu() -> NSMenu {
        let mainMenu = NSMenu(title: "MainMenu")
        let submenu = mainMenu.addItem(withTitle: "Application", action: nil, keyEquivalent: "")
        let menu = NSMenu(title: "Application")
        mainMenu.setSubmenu(menu, for: submenu)

        return mainMenu
    }

    private func createApplicationMenu(_ mainMenu: NSMenu, name: String) {
        let submenu = mainMenu.addItem(withTitle: "Application", action: nil, keyEquivalent: "")
        let menu = NSMenu(title: "Application")
        mainMenu.setSubmenu(menu, for: submenu)
        
        var title = "About".localized + " " + name
        var menuItem = menu.addItem(withTitle: title, action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        menuItem.target = NSApp
        
        menu.addItem(NSMenuItem.separator())
        
        title = "Services".localized
        menuItem = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        let servicesMenu = NSMenu(title: "Services")
        menu.setSubmenu(servicesMenu, for: menuItem)
        NSApp.servicesMenu = servicesMenu
        
        menu.addItem(NSMenuItem.separator())
        
        title = "Hide".localized + " " + name
        menuItem = menu.addItem(withTitle: title, action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        menuItem.target = NSApp
        
        title = "Hide Others".localized
        menuItem = menu.addItem(withTitle: title, action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        menuItem.keyEquivalentModifierMask = [.command, .option]
        menuItem.target = NSApp
        
        title = "Show all".localized
        menuItem = menu.addItem(withTitle: title, action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        menuItem.target = NSApp
        
        menu.addItem(NSMenuItem.separator())
        
        title = "Quit".localized + " " + name
        menuItem = menu.addItem(withTitle:title, action:#selector(NSApplication.terminate(_:)), keyEquivalent:"q")
        menuItem.target = NSApp
    }
    
    private func createFileMenu(_ mainMenu: NSMenu, name: String) {
        let submenu = mainMenu.addItem(withTitle: "File", action: nil, keyEquivalent: "")
        let menu = NSMenu(title: "File")
        mainMenu.setSubmenu(menu, for: submenu)
        
        var title = "Close Window".localized
        menu.addItem(withTitle: title, action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")

        menu.addItem(NSMenuItem.separator())

        title = "Add Sprite to Project".localized
        menu.addItem(withTitle: title, action: #selector(AppDelegate.addSprite(_:)), keyEquivalent: "N")
        title = "Add Example Sprite to Project".localized
        menu.addItem(withTitle: title, action: #selector(AppDelegate.addExampleSprite(_:)), keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())
        
        title = "Import Image file...".localized
        menu.addItem(withTitle: title, action: #selector(AppDelegate.importImage(_:)), keyEquivalent: "")

        title = "Import Sprite file (.spr)...".localized
        menu.addItem(withTitle: title, action: #selector(AppDelegate.importSPR(_:)), keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())

        title = "Export as Sprite file (.spr)...".localized
        menu.addItem(withTitle: title, action: #selector(AppDelegate.exportSPR(_:)), keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())

        title = "Save Project".localized
        menu.addItem(withTitle: title, action: #selector(AppDelegate.save(_:)), keyEquivalent: "s")

        menu.addItem(NSMenuItem.separator())
    }
    
    private func createEditMenu(_ mainMenu: NSMenu, name: String) {
        let submenu = mainMenu.addItem(withTitle: "Edit", action: nil, keyEquivalent: "")
        let menu = NSMenu(title: "Edit")
        mainMenu.setSubmenu(menu, for: submenu)
        
        var title = "Cut".localized
        menu.addItem(withTitle:title, action:#selector(NSText.cut(_:)), keyEquivalent:"x")
        
        title = "Copy".localized
        menu.addItem(withTitle:title, action:#selector(NSText.copy(_:)), keyEquivalent:"c")
        
        title = "Paste".localized
        menu.addItem(withTitle:title, action:#selector(NSText.paste(_:)), keyEquivalent:"v")
        
        title = "Paste and Match Style".localized
        let menuItem = menu.addItem(withTitle:title, action:#selector(NSTextView.pasteAsPlainText(_:)), keyEquivalent:"V")
        menuItem.keyEquivalentModifierMask = [.command, .option]
        
        title = "Delete".localized
        menu.addItem(withTitle:title, action:#selector(NSText.delete(_:)), keyEquivalent:"\u{8}") // backspace
        
        title = "Select All".localized
        menu.addItem(withTitle:title, action:#selector(NSText.selectAll(_:)), keyEquivalent:"a")
    }
    
    private func createViewMenu(_ mainMenu: NSMenu, name: String) {
        let submenu = mainMenu.addItem(withTitle: "View", action: nil, keyEquivalent: "")
        let menu = NSMenu(title: "View")
        mainMenu.setSubmenu(menu, for: submenu)

        let title = "Console on/off".localized
        _ = menu.addItem(withTitle: title, action: #selector(AppDelegate.toggleConsole(_:)), keyEquivalent: "C")

        menu.selectChildWithTag(20, true)
    }
    
    private func createMenu() {
        self.menu = NSMenu(title: "MainMenu")
        NSApp.mainMenu = self.menu
        
        createApplicationMenu(self.menu, name: self.applicationName)
        createFileMenu(self.menu, name: self.applicationName)
        createEditMenu(self.menu, name: self.applicationName)
        createViewMenu(self.menu, name: self.applicationName)
    }

    // -------------------------------------------------------------------------
    // MARK: - Windows delegate

    func windowWillClose(_ notification: Notification) {
    }

    // -------------------------------------------------------------------------
    // MARK: - Split view delegate
    
    func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        // Lock dragging
        return NSRect.zero
    }
    
    func splitView(_ splitView: NSSplitView, resizeSubviewsWithOldSize oldSize: NSSize) {
        guard let mySplitView = splitView as? MySplitView else { return }
        
        if mySplitView.userTag == 1 {
            let view1 = splitView.subviews[0]
            let view2 = splitView.subviews[1]
            let view3 = splitView.subviews[2]

            let viewWidth1: CGFloat = 200
            let viewWidth3: CGFloat = 320
            let viewWidth2: CGFloat = splitView.frame.size.width-viewWidth1-viewWidth3-2*splitView.dividerThickness

            let viewFrame1 = NSMakeRect(0, 0, viewWidth1, splitView.frame.size.height)
            let viewFrame2 = NSMakeRect(viewWidth1+splitView.dividerThickness, 0, viewWidth2, splitView.frame.size.height)
            let viewFrame3 = NSMakeRect(viewWidth1+viewWidth2+2*splitView.dividerThickness, 0, viewWidth3, splitView.frame.size.height)

            view1.frame = viewFrame1
            view2.frame = viewFrame2
            view3.frame = viewFrame3
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Create window and views

    private func createContentView() {
        let topSplitView = MySplitView(frame: self.window.contentView!.bounds)
        topSplitView.isVertical = true
        topSplitView.userTag = 1
        topSplitView.dividerStyle = .thin
        topSplitView.delegate = self
        topSplitView.autoresizingMask = [.width, .height]
        self.window.contentView?.addSubview(topSplitView)

        let myCommandView = CommandView(frame: self.window.contentView!.bounds)
        myCommandView.autoresizingMask = [.width, .height]
        topSplitView.addArrangedSubview(myCommandView)

        let mySpriteView = SpriteEditView(frame: self.window.contentView!.bounds)
        mySpriteView.autoresizingMask = [.width, .height]
        topSplitView.addArrangedSubview(mySpriteView)

        let myPropertyView = PropertyView(frame: self.window.contentView!.bounds)
        myPropertyView.autoresizingMask = [.width, .height]
        topSplitView.addArrangedSubview(myPropertyView)

        self.window.makeFirstResponder(mySpriteView)
    }
    
    private func createWindow(_ title: String) {
        let contentRect = NSMakeRect(5, 110, 1800, 1100)
        let styleMask: NSWindow.StyleMask = [NSWindow.StyleMask.titled, NSWindow.StyleMask.closable, NSWindow.StyleMask.miniaturizable, NSWindow.StyleMask.resizable]
        
        self.window = NSWindow(contentRect: contentRect, styleMask:styleMask, backing: NSWindow.BackingStoreType.buffered, defer: true)
        self.window.title = title
        self.window.delegate = self
        self.window.makeKeyAndOrderFront(nil)
        
        createContentView()
    }
    
    private func createConsole() {
        self.console = ConsolePanel(contentRect: NSMakeRect(1000, 1500, 700, 200))
        self.console.isHidden = true
    }

    func createUI() {
        createConsole()

        createWindow("")
        createMenu()
        createToolbar()
        
        self.register(for: .currentProjectChanged, observer: self)
        self.register(for: .currentSpriteChanged, observer: self)
        self.register(for: .colorChanged, observer: self)
        self.register(for: .transColorChanged, observer: self)
        self.register(for: .paletteChanged, observer: self)

        self.toolbar.colorForItem("color", color: ProjectManager.shared.color)
        self.toolbar.colorForItem("transColor", color: ProjectManager.shared.transparentColor)
    }

    // -------------------------------------------------------------------------
    
    class MySplitView : NSSplitView {
        var userTag = 0
    }

}


