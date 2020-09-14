
import Cocoa

class SpriteEditView : RBView, NSSplitViewDelegate, RBObserver {
    private var spriteListView: SpriteListView!
    private var spriteSize: CGFloat = 16;
    private var scale: CGFloat = 20;
    private var data: [Int] = []

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
        var location: CGPoint = gestureRecognizer.location(in: self)

        var colorIndex = ProjectManager.shared.paletteColorIndex
        if ProjectManager.shared.pencilMode == 2 {
            colorIndex = ProjectManager.shared.paletteTransparentColorIndex
        }

        let width: CGFloat = spriteSize * scale
        let height: CGFloat = spriteSize * scale
        let x = (self.bounds.size.width-width)/2
        let y = (self.bounds.size.height-height)/2

        location.x -= x
        location.y -= y

        let h = Int(location.x) / Int(scale)
        let v = Int(location.y) / Int(scale)
        
        let index = v * Int(spriteSize) + h
        
        if index < 0 || index > 255 {
            return
        }
        
        // Colo rpicker mode
        if ProjectManager.shared.pencilMode == 3 {
            ProjectManager.shared.paletteTransparentColorIndex = data[index]
            return
        }

        data[index] = colorIndex
        
        if ProjectManager.shared.mirrorH && ProjectManager.shared.mirrorV {
            if (h != Int(spriteSize)-1) || (v != Int(spriteSize) - 1) {
                let newH = mirrorHorizontal(h, vertical: v, colorIndex: colorIndex)
                mirrorVertical(v, horizontal: h, colorIndex: colorIndex)
                mirrorVertical(v, horizontal: newH, colorIndex: colorIndex)
            }
        }
        else if ProjectManager.shared.mirrorH {
            mirrorHorizontal(h, vertical: v, colorIndex: colorIndex)
        }
        else if ProjectManager.shared.mirrorV {
            mirrorVertical(v, horizontal: h, colorIndex: colorIndex)
        }

        self.needsDisplay = true
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Draw

    private func drawData() {
        let width: CGFloat = spriteSize * scale
        let height: CGFloat = spriteSize * scale
        let x = (self.bounds.size.width-width)/2
        let y = (self.bounds.size.height-height)/2

        // TODO: Specify transparent color
        for v in 0...Int(spriteSize-1) {
            for h in 0...Int(spriteSize-1) {
                let pos = v*Int(spriteSize)+h
                let index = data[pos]
                
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

    private func drawLine(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) {
        let line = NSBezierPath()
        line.move(to: CGPoint.make(x1, y1))
        line.line(to: CGPoint.make(x2, y2))
        line.lineWidth = 1.0
        line.stroke()
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
        let width: CGFloat = spriteSize * scale
        let height: CGFloat = spriteSize * scale
        let x = (self.bounds.size.width-width)/2
        let y = (self.bounds.size.height-height)/2
        
        NSColor.white.setFill()
        NSRect.make(x, y, width, height).fill()

        drawGrid()
        drawData()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Data manipulation

    private func rotateXY(source: OSPoint, degrees: OSFloat, offset: OSPoint) -> OSPoint? {
        var result = OSPoint()

        let radians = degrees * OSFloat(Double.pi) / 180.0
        
        result.x = (source.x - offset.x) * cos(radians) - (source.y - offset.y) * sin(radians) + offset.x;
        result.y = (source.x - offset.x) * sin(radians) + (source.y - offset.y) * cos(radians) + offset.y;
        
        result.x = ceil(result.x)
        result.y = ceil(result.y)

        if result.x < 0 || result.y < 0 {
            return nil
        }
        
        if result.x > spriteSize-1 || result.y > spriteSize-1 {
            return nil
        }

        return result
    }

    private func rotate(degrees: OSFloat) -> [[Int]] {
        var result = Array(repeating: Array(repeating: ProjectManager.shared.paletteTransparentColorIndex, count: Int(spriteSize)), count: Int(spriteSize))

        for v in 0...Int(spriteSize-1) {
            for h in 0...Int(spriteSize-1) {
                let index = v * Int(spriteSize) + h
                let value = data[index]
                
                if value != ProjectManager.shared.paletteTransparentColorIndex {
                    if let point = rotateXY(source: OSPoint.make(h, v), degrees: degrees, offset: OSPoint.make(spriteSize/2, spriteSize/2)) {
                        result[Int(point.x)][Int(point.y)] = value
                    }
                }
            }
        }

        return result
    }
    
    private func rotate45() {
        let result = rotate(degrees: 45)
        
        for v in 0...Int(spriteSize-1) {
            for h in 0...Int(spriteSize-1) {
                let index = v * Int(spriteSize) + h
                data[index] = result[v][h]
            }
        }
    }

    private func rotateClockwise(mat: [[Int]]) -> [[Int]] {
        let M = mat.count
        let N = mat[0].count
        
        var ret = Array(repeating: Array(repeating: 0, count: Int(spriteSize)), count: Int(spriteSize))

        for r in 0..<M {
            for c in 0..<N {
                ret[c][M-1-r] = mat[r][c]
            }
        }
                
        return ret
    }

    private func rotate90() {
        var twoD = Array(repeating: Array(repeating: 0, count: Int(spriteSize)), count: Int(spriteSize))
        
        for v in 0...Int(spriteSize-1) {
            for h in 0...Int(spriteSize-1) {
                let index = v * Int(spriteSize) + h
                twoD[v][h] = data[index]
            }
        }
        
        let result = rotateClockwise(mat: twoD)
        
        for v in 0...Int(spriteSize-1) {
            for h in 0...Int(spriteSize-1) {
                let index = v * Int(spriteSize) + h
                data[index] = result[v][h]
            }
        }
    }
    
    @discardableResult
    private func mirrorHorizontal(_ horizontal: Int, vertical: Int, colorIndex: Int) -> Int {
        // Test for mirror function
        let middle = Int(spriteSize/2)-1
        let offset = (middle-horizontal)
        let newH = middle+offset

        let newIndex = vertical * Int(spriteSize) + newH
        
        if newIndex >= 0 {
            data[newIndex] = colorIndex
        }

        return newH
    }
    
    @discardableResult
    private func mirrorVertical(_ vertical: Int, horizontal: Int, colorIndex: Int) -> Int {
        // Test for mirror function
        let middle = Int(spriteSize/2)-1
        let offset = (middle-vertical)
        let newV = middle+offset

        let newIndex = newV * Int(spriteSize) + horizontal
        
        if newIndex >= 0 {
            data[newIndex] = colorIndex
        }
    
        return newV
    }

    private func fillData(_ value: Int) {
        for i in 0...data.count-1 {
            data[i] = value
        }
    }
    
    private func fillEmpty(_ value: Int) {
        for i in 0...data.count-1 {
            if data[i] == ProjectManager.shared.paletteTransparentColorIndex {
                data[i] = value
            }
        }
    }
    
    private func moveHorizontal(offset: Int) {
        if offset == 1 {
            for v in 0..<Int(spriteSize) {
                var h = Int(spriteSize-2)
                
                while h >= 0 {
                    let index1 = v * Int(spriteSize) + h
                    let index2 = v * Int(spriteSize) + h+1

                    data[index2] = data[index1]
                    
                    if h == 0 {
                        data[index1] = ProjectManager.shared.paletteTransparentColorIndex
                    }

                    h = h - 1
                }
            }
        }
        else if offset == -1 {
            for v in 0..<Int(spriteSize) {
                var h = 1
                
                while h <= Int(spriteSize-1) {
                    let index1 = v * Int(spriteSize) + h
                    let index2 = v * Int(spriteSize) + h-1

                    data[index2] = data[index1]
                    
                    if h == Int(spriteSize-1) {
                        data[index1] = ProjectManager.shared.paletteTransparentColorIndex
                    }

                    h = h + 1
                }
            }
        }
        else  {
            return
        }
    }
    
    private func loopHorizontal(offset: Int) {
        if offset == 1 {
            for v in 0..<Int(spriteSize) {
                var h = Int(spriteSize-2)
                
                let index3 = v * Int(spriteSize) + Int(spriteSize)-1
                let save = data[index3]
                
                while h >= 0 {
                    let index1 = v * Int(spriteSize) + h
                    let index2 = v * Int(spriteSize) + h+1

                    data[index2] = data[index1]

                    if h == 0 {
                        data[index1] = save
                    }

                    h = h - 1
                }
            }
        }
        else if offset == -1 {
            for v in 0..<Int(spriteSize) {
                var h = 1

                let index3 = v * Int(spriteSize) + 0
                let save = data[index3]

                while h <= Int(spriteSize-1) {
                    let index1 = v * Int(spriteSize) + h
                    let index2 = v * Int(spriteSize) + h-1

                    data[index2] = data[index1]
                    
                    if h == Int(spriteSize-1) {
                        data[index1] = save
                    }

                    h = h + 1
                }
            }
        }
        else  {
            return
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Create text
    
    private func createC() {
        var text = "static const uint8_t sprite_data[] = {\n  "
        
        for i in 0...data.count-1 {
            let value = data[i]
                        
            if i == data.count-1 {
                text = text + String(format:"0x%02X", value)
            }
            else {
                text = text + String(format:"0x%02X,", value)
            }

            if (i+1) % 16 == 0 && i > 0 && i < data.count-1 {
                text = text + "\n  "
            }
        }
        
        text = text + "\n};"
        
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(text, forType: NSPasteboard.PasteboardType.string)
    }
    
    private func createASM() {
        var text = "sprite:\n\tdb "
        
        for i in 0...data.count-1 {
            let value = data[i]
                        
            if i == data.count-1 {
                text = text + String(format:"0x%02X;", value)
            }
            else {
                text = text + String(format:"0x%02X", value)
            }

            if (i+1) % 16 == 0 && i > 0 && i < data.count-1 {
                text = text + ";\n\tdb "
            }
            else if i < data.count-1 {
                text = text + ","
            }
        }
        
        text = text + ""
        
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(text, forType: NSPasteboard.PasteboardType.string)
    }

    // -------------------------------------------------------------------------
    // MARK: - Sprite handling

    private func modifySprite(command: Commands) {
        switch command {
            case .loopHN:
                loopHorizontal(offset: -1)
            case .loopHP:
                loopHorizontal(offset: 1)
            case .loopVN:
                break
            case .loopVP:
                break
            case .moveHN:
                moveHorizontal(offset: -1)
            case .moveHP:
                moveHorizontal(offset: 1)
            case .moveVN:
                break
            case .moveVP:
                break
            case .fillEmpty:
                fillEmpty(ProjectManager.shared.paletteColorIndex)
            case .fillAll:
                fillData(ProjectManager.shared.paletteColorIndex)
            case .empty:
                fillData(ProjectManager.shared.paletteTransparentColorIndex)
            case .rotate90:
                 rotate90()
            case .rotate45:
                 rotate45()
            case .createC:
                createC()
            case .createASM:
                createASM()
                break
        }
        
    }
    
    private func saveSprite() {
        if data.count == 0 {
            return
        }
        
        ProjectManager.shared.saveSpriteData(data)
    }

    private func loadSprite() {
        data.removeAll()
        data = ProjectManager.shared.loadSpriteData(number: ProjectManager.shared.currentSprite)
    }

    private func resetData() {
        data.removeAll()
        
        // fill
        let count = spriteSize*spriteSize
        for _ in 1...Int(count) {
            data.append(-1)
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Observer

    func onReceive(action: ObserverAction, from sender: Any?) {
        switch action {
        case .transColorChanged:
            needsDisplay = true
        case .paletteChanged:
            needsDisplay = true
        case .gridChanged:
            scale = ProjectManager.shared.zoom
            needsDisplay = true
        case .sizeChanged:
            if spriteSize != ProjectManager.shared.size {
                resetData()
                spriteSize = ProjectManager.shared.size
                needsDisplay = true
            }
        case .currentSpriteWillClose:
            saveSprite()
        case .currentSpriteChanged:
            loadSprite()
            needsDisplay = true
        case .dataMustBeSaved:
            saveSprite()
        case .command:
            if let command = sender as? Commands {
                modifySprite(command: command)
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

        let rect = NSRect.make(10, 10, 36, 20+16*(16+4))
        spriteListView = SpriteListView(frame: rect)
        self.addSubview(spriteListView)
        //resetData()
        
        // Gestures
        var gestureRecognizers = self.gestureRecognizers
        
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        gestureRecognizers.insert(clickGesture, at: 0)
        self.gestureRecognizers = gestureRecognizers

        self.register(for: .transColorChanged, observer: self)
        self.register(for: .gridChanged, observer: self)
        self.register(for: .sizeChanged, observer: self)
        self.register(for: .paletteChanged, observer: self)
        self.register(for: .currentSpriteChanged, observer: self)
        self.register(for: .currentSpriteWillClose, observer: self)
        self.register(for: .dataMustBeSaved, observer: self)
        self.register(for: .command, observer: self)
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



