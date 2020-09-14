
import Cocoa

typealias RBNSToolbarCallback = (Int, Any) -> ()

class RBNSToolbar : NSToolbar, NSToolbarDelegate {
    private var _items = Dictionary<String, NSToolbarItem>()
    private var _identifiers = Array<NSToolbarItem.Identifier>()
    private var _callbacks = Array<RBNSToolbarCallback?>()
    
    // -------------------------------------------------------------------------
    // MARK: - Properties

    func itemWithName(_ name: String) -> NSToolbarItem? {
        return _items[name]
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Color handling
    
    func chooserForItem(_ name: String) -> NSColorWell? {
        if let item = _items[name] {
            if let colorWell = item.view as? NSColorWell {
                return colorWell
            }
        }
        
        return nil
    }
    
    func colorForItem(_ name: String, color: OSColor) {
        if let chooser = chooserForItem(name) {
            chooser.color = color
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Segment handling
    
    func segmentForItem(_ name: String) -> NSSegmentedControl? {
        if let item = _items[name] {
            if let segment = item.view as? NSSegmentedControl {
                return segment
            }
        }
        
        return nil
    }
    
    func enableSegment(_ name: String, enable: Bool) {
        if let segment = segmentForItem(name) {
            segment.isEnabled = enable
        }
    }
    
    func selectSegmentItem(_ name: String, item: Int) {
        if let segment = segmentForItem(name) {
            segment.selectedSegment = item
        }
    }
    
    func setSegmentFont(_ name: String, font: NSFont) {
        if let segment = segmentForItem(name) {
            segment.font = font
        }
    }
    
    func selectionSegment(_ name: String) -> Int? {
        if let segment = segmentForItem(name) {
            return segment.selectedSegment
        }
        
        return nil
    }

    // -------------------------------------------------------------------------
    // MARK: - Item actions
    
    @objc func buttonPressed(_ button: NSButton) {
        let tag = button.tag - 1
        let callback = _callbacks[tag]
        
        if callback == nil {
            return
        }

        callback?(0, button)
    }

    @objc func togglePressed(_ button: NSButton) {
        let tag = button.tag - 1
        let callback = _callbacks[tag]
        
        if callback == nil {
            return
        }

        if button.title == "On" {
            button.title = "Off"
            
            callback?(0, button)
        }
        else {
            button.title = "On"
            
            callback?(1, button)
        }
    }
    
    @objc func colorWellPressed(_ colorWell: NSColorWell) {
        let tag = colorWell.tag - 1
        let colorWellCallback = _callbacks[tag]
        
        if colorWellCallback != nil {
            colorWellCallback?(tag, colorWell.color)
        }
    }
    
    @objc func segmentPressed(_ segment: NSSegmentedControl) {
        let tag = segment.tag - 1
        let segmentCallback = _callbacks[tag]
        
        if segmentCallback != nil {
            segmentCallback?(segment.selectedSegment, segment)
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Item adding

    func addItem(name: String, title: String, icon: NSImage? = nil, width: CGFloat = 50, _ callback: RBNSToolbarCallback? = nil) {
        var name = name
        let item = _items[name]
        if item != nil {
            name = name + "\(_items.count)"
        }

        // Add identifier
        let identifier = NSToolbarItem.Identifier(name)
        _identifiers.append(identifier)
        
        let button = NSButton(frame: NSMakeRect(0, 0, width, 32))
        button.image = icon
        button.target = self
        button.action = #selector(buttonPressed(_:))
        button.bezelStyle = .texturedSquare
        button.title = ""
        
        // Add item
        let toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        toolbarItem.label = title.localized
        toolbarItem.view = button
        _items[name] = toolbarItem
        
        let tag = _callbacks.count + 1
        button.tag = tag
        _callbacks.append(callback)
    }
    
    func addItemToggle(name: String, title: String, _ callback: RBNSToolbarCallback? = nil) {
        var name = name
        let item = _items[name]
        if item != nil {
            name = name + "\(_items.count)"
        }
        
        if item != nil {
            rbWarning("Toolbar identifier \(name) already used")
            return
        }
        
        // Add identifier
        let identifier = NSToolbarItem.Identifier(name)
        _identifiers.append(identifier)
        
        let button = NSButton(frame: NSMakeRect(0, 0, 50, 32))
        button.target = self
        button.action = #selector(togglePressed(_:))
        button.bezelStyle = .texturedSquare
        button.title = "Off"
        
        // Add item
        let toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        toolbarItem.label = title.localized
        toolbarItem.view = button
        _items[name] = toolbarItem
        
        let tag = _callbacks.count + 1
        button.tag = tag
        _callbacks.append(callback)
    }
    
    func addSpace(_ width: Int) {
        var name = "space\(width)"
        let item = _items[name]
        
        if item != nil {
            name = name + "\(_items.count)"
        }
        
        // Add identifier
        let identifier = NSToolbarItem.Identifier(name)
        _identifiers.append(identifier)
        
        let view = NSView(frame: NSMakeRect(0, 0, CGFloat(width), 32))
        
        // Add item
        let toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        toolbarItem.view = view
        _items[name] = toolbarItem
    }
    
    func addLabel(name: String, title: String, width: Int) {
        var name = name

        let item = _items[name]
        
        if item != nil {
            name = name + "\(_items.count)"
        }
        
        // Add identifier
        let identifier = NSToolbarItem.Identifier(name)
        _identifiers.append(identifier)
        
        let view = RBTextLabel(frame: NSMakeRect(0, 0, CGFloat(width), 32))
        view.setText(title)
        
        // Add item
        let toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        toolbarItem.view = view
        _items[name] = toolbarItem
    }

    @discardableResult
    func addSegment(name: String, multiple: Bool = false, title: String, width: CGFloat, _ labels: [String], _ icons: [String?], _ callback: RBNSToolbarCallback? = nil) -> (NSSegmentedControl, NSToolbarItem?) {
        var name = name
        let item = _items[name]
        if item != nil {
            name = name + "\(_items.count)"
        }
        
        // Add identifier
        let identifier = NSToolbarItem.Identifier(name)
        _identifiers.append(identifier)
        
        let mode: NSSegmentedControl.SwitchTracking = multiple ? .selectAny : .selectOne
        let segment = NSSegmentedControl(labels: labels, trackingMode: mode, target: self, action: #selector(segmentPressed(_:)))
        if !multiple {
            segment.setSelected(true, forSegment: 0)
        }
        else {
            segment.font = NSFont.boldSystemFont(ofSize: 11)
        }
        
        segment.frame = NSMakeRect(0, 0, CGFloat(labels.count)*width+10, 32)
        segment.segmentStyle = .texturedRounded
        
        // Add icons
        for i in 0..<labels.count {
            if let icon = i < icons.count ? icons[i] : nil {
                segment.setImage(OSImage.getImage(named: icon), forSegment: i)
                segment.setWidth(width, forSegment: i)
            }
        }
        
        // Add item
        let toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        toolbarItem.label = title
        toolbarItem.view = segment
        _items[name] = toolbarItem
        
        let tag = _callbacks.count + 1
        segment.tag = tag
        _callbacks.append(callback)
        
        return (segment, toolbarItem)
    }
    
    @discardableResult
    func addColorWell(name: String, title: String, width: CGFloat, _ callback: RBNSToolbarCallback? = nil) -> (NSColorWell, NSToolbarItem?) {
        var name = name
        let item = _items[name]
        if item != nil {
            name = name + "\(_items.count)"
        }

        // Add identifier
        let identifier = NSToolbarItem.Identifier(name)
        _identifiers.append(identifier)
        
        let colorWell = NSColorWell(frame: NSMakeRect(0, 0, width, 32))
        colorWell.target = self
        colorWell.action = #selector(colorWellPressed(_:))
        
        // Add item
        let toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        toolbarItem.label = title
        toolbarItem.view = colorWell
        _items[name] = toolbarItem
        
        let tag = _callbacks.count + 1
        colorWell.tag = tag
        _callbacks.append(callback)
        
        return (colorWell, toolbarItem)
    }

    
    @discardableResult
    func addPatternChooser(name: String, title: String, width: CGFloat, _ callback: @escaping RBNSToolbarCallback) -> (RBPatternView, NSToolbarItem?) {
        var name = name
        let item = _items[name]
        if item != nil {
            name = name + "\(_items.count)"
        }

        // Add identifier
        let identifier = NSToolbarItem.Identifier(name)
        _identifiers.append(identifier)
        
        let patternChooser = RBPatternView(frame: NSMakeRect(0, 0, width, 32))
        patternChooser.patterns = Settings.UI.numberOfPatterns
        patternChooser.callback = { (chooser) in
            let tag = chooser.number - 1
            let patternChooserCallback = self._callbacks[tag]
            
            if patternChooserCallback != nil {
                patternChooserCallback?(chooser.pattern, patternChooser)
            }
        }
        
        // Add item
        let toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        toolbarItem.label = title
        toolbarItem.view = patternChooser
        _items[name] = toolbarItem
        
        let tag = _callbacks.count + 1
        patternChooser.number = tag
        _callbacks.append(callback)
        
        return (patternChooser, toolbarItem)
    }

    func addMenu(name: String) {
        // TODO: Menus not yet working
        rbWarning("Toolbar menus not yet working")

        // Get item
        let item = _items[name]
        
        if item != nil {
            rbWarning("Toolbar identifier \(name) already used")
            return
        }
        
        // Add identifier
        let identifier = NSToolbarItem.Identifier(name)
        _identifiers.append(identifier)

        // Create menu
        let submenu = NSMenu()
        let submenuItem = NSMenuItem(title: "Title", action: #selector(buttonPressed(_:)), keyEquivalent: "")
        submenuItem.target = self
        submenuItem.action = #selector(buttonPressed(_:))
        submenu.addItem(submenuItem)
        
        // Create representation
        let menuFormRep = NSMenuItem()
        menuFormRep.submenu = submenu
        menuFormRep.title = "Title"
        
        // Add item
        let toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        toolbarItem.label = name
        toolbarItem.image = NSImage(named: NSImage.addTemplateName)
        toolbarItem.menuFormRepresentation = menuFormRep

        _items[name] = toolbarItem
    }

    // -------------------------------------------------------------------------
    // MARK: - Delegates

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        return _items[itemIdentifier.rawValue]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return _identifiers
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return _identifiers
    }
    
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return _identifiers
    }

    // -------------------------------------------------------------------------
    // MARK: - Initialisation
    
    init(name: String) {
        super.init(identifier: name)

        self.delegate = self
        self.allowsUserCustomization = false
        self.showsBaselineSeparator = true
    }
    
    // -------------------------------------------------------------------------
    
}



