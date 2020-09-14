//

import Cocoa

enum Commands : Int {
    case loopHN = 1
    case loopHP
    case loopVN
    case loopVP
    case moveHN
    case moveHP
    case moveVN
    case moveVP
    case fillEmpty
    case fillAll
    case empty
    case rotate90
    case rotate45
    case createC
    case createASM
}

class CommandView : NSView, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    private var _segment: NSSegmentedControl!
    private var _scrollView: NSScrollView!
    private var _collectionView: NSCollectionView!

    private let commands = ["Loop H-", "Loop H+", "Loop V-", "Loop V+",
                            "Move H- ⚠︎", "Move H+ ⚠︎","Move V- ⚠︎", "Move V+ ⚠︎",
                            "Fill Empty", "Fill All ⚠︎",
                            "Empty ⚠︎", "Rotate 90", "Rotate 45",
                            "Create C-Array", "Create ASM Data"]

    private let active = [true, true, false, false, true, true, false, false, true, true, true, true, true, true, true]
    
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
    
    @objc
    func segmentPressed(_ segment: NSSegmentedControl) {
    }
    
    @objc
    func handleCommandAction(_ sender: NSButton) {
        let index = sender.tag
        rbDebug("Execute \(commands[index-1])")

        if let command = Commands(rawValue: index) {
            notify(with: .command, sender: command)
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Delegate & Data Source

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return commands.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let viewItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CommandItem"), for: indexPath)
 
        if let commandItem = viewItem as? CommandItem {
            commandItem.applyCommand(commands[indexPath.item], key: "", tag: indexPath.item+1, target: self, action: #selector(handleCommandAction(_:)))
            commandItem.setEnable(active[indexPath.item])
        }
        
        return viewItem
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 200, height: 30)
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        return NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // -------------------------------------------------------------------------
    // MARK: - View life cycle
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        let titleHeight: CGFloat = 22
        
        _segment.setWidth(self.bounds.size.width, forSegment: 0)
        _segment.frame = NSMakeRect(0, self.bounds.size.height-titleHeight, self.bounds.size.width, titleHeight)

        _scrollView.frame = NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height-titleHeight)
        _collectionView.frame = NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height-titleHeight)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Initialisation
    
    private func initView() {
        self.wantsLayer = true
        self.layer?.backgroundColor = Settings.UI.CommandView.background.cgColor

        _segment = NSSegmentedControl(labels: ["Tools"], trackingMode: .momentary, target: self, action: #selector(segmentPressed(_:)))
        _segment.frame = NSMakeRect(0, 0, 100, 32)
        _segment.segmentStyle = .smallSquare
        self.addSubview(_segment)

        _scrollView = NSScrollView(frame:NSMakeRect(0, 0, 200, 300))
        _scrollView.hasVerticalScroller = true
        _scrollView.backgroundColor = NSColor.yellow // Settings.UI.CommandView.background
        
        _collectionView = NSCollectionView(frame: NSZeroRect)
        _collectionView.collectionViewLayout = NSCollectionViewFlowLayout()
        _collectionView.dataSource = self
        _collectionView.delegate = self

        _scrollView.documentView = _collectionView
        
        self.addSubview(_scrollView)
        
        _collectionView.register(CommandItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CommandItem"))

        _collectionView.reloadData()
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

class CommandItem: NSCollectionViewItem {
    private var _itemView: CommandItemView?

    func setEnable(_ flag: Bool) {
        guard let button = _itemView?._button else { return }
        button.isEnabled = flag
    }

    func applyCommand(_ command: String, key: String, tag: Int, target: AnyObject, action: Selector) {
        _itemView?.applyCommand(command, key: key, tag: tag, target: target, action: action)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        _itemView = CommandItemView(frame: NSZeroRect)
        view = _itemView!
    }
}

class CommandItemView: NSView {
    
    var _button: NSButton!

    func applyCommand(_ command: String, key: String, tag: Int, target: AnyObject, action: Selector) {
        _button.title = " ▶︎ " + command
        _button.tag = tag
        _button.target = target
        _button.action = action
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        _button.frame = self.bounds
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initView()
    }
    
    func initView() {
        _button = NSButton(frame: self.bounds)
        _button.bezelStyle = .texturedSquare
        _button.alignment = .left
        self.addSubview(_button)
    }

}
