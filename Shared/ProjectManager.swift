
import Foundation

class ProjectManager : NSObject {
    private let fileExtension = Settings.File.ext
    
    // Project related
    private var _project: String = ""
    private var _listOfSprites = Array<Int>()
    private var _spriteNumber: Int = 0
    private var _palette = Array<OSColor>()
    private var _usesProjectPalette = true
    
    // Settings
    private let _transColorIndex = 256
    private var _zoom: CGFloat = 20
    private var _size: CGFloat = 16
    private var _pattern = 1
    private var _colorIndex = 0
    private var _mirrorH = false
    private var _mirrorV = false
    private var _pencilMode = 1
    private var _showTransparentColor = false
    
    // -------------------------------------------------------------------------
    // MARK: - Properties
    
    override var description: String {
        get {
            let className = type(of: self)
            return "\(className)-\(self.hash)"
        }
    }
    
    var pathOfCurrentSprite: String {
        get {
            return pathForSpriteFile(number: _spriteNumber)
        }
    }
    
    var spriteList: Array<Int> {
        get {
            return _listOfSprites
        }
    }
    
    var nameOfProject: String {
        get {
            return _project
        }
        set(value) {
            _project = value
        }
    }
    
    var currentSprite: Int {
        get {
            return _spriteNumber
        }
    }
    
    var numberOfSprites: Int {
        get {
            return _listOfSprites.count
        }
    }

    var numberOfPaletteEntries: Int {
        get {
            // Dont count transparency color at the end
            return _palette.count - 1
        }
    }

    func colorFromPalette(index: Int) -> OSColor {
        guard index >= 0, index < _palette.count else { return OSColor.red }
        return _palette[index]
    }

    // -------------------------------------------------------------------------
    // MARK: - Settings Properties
    
    var showTransparentColor: Bool {
        get {
            return _showTransparentColor
        }
        set(value) {
            _showTransparentColor = value
            notify(with: .transColorChanged, sender: ProjectManager.shared)
        }
    }

    var pencilMode: Int {
        get {
            return _pencilMode
        }
        set(value) {
            _pencilMode = value
        }
    }

    var zoom: OSFloat {
        get {
            return _zoom
        }
        set(value) {
            _zoom = value
            notify(with: .gridChanged, sender: ProjectManager.shared)
        }
    }
    
    var size: OSFloat {
        get {
            return _size
        }
        set(value) {
            _size = value
            notify(with: .sizeChanged, sender: ProjectManager.shared)
        }
    }
    
    var color: OSColor {
        get {
            return colorFromPalette(index: _colorIndex)
        }
    }
    
    var transparentColor: OSColor {
        get {
            return colorFromPalette(index: _transColorIndex)
        }
    }

    var pattern: Int {
        get {
            return _pattern
        }
        set(value) {
            _pattern = value
        }
    }
    
    var paletteColorIndex: Int {
        get {
            return _colorIndex
        }
        set(value) {
            _colorIndex = value
            
            notify(with: .colorChanged, sender: ProjectManager.shared)
        }
    }
    
    var paletteTransparentColorIndex: Int {
        get {
            return _transColorIndex
        }
        set(value) {
            let color = _palette[value]
            _palette[_transColorIndex] = color

            saveCurrentPalette()
            
            notify(with: .transColorChanged, sender: ProjectManager.shared)
        }
    }

    var mirrorH: Bool {
        return _mirrorH
    }
    
    var mirrorV: Bool {
        return _mirrorV
    }

    func toggleMirrorH() {
        _mirrorH = !_mirrorH
    }
    
    func toggleMirrorV() {
        _mirrorV = !_mirrorV
    }

    // -------------------------------------------------------------------------
    // MARK: - Helper methods

    private func refreshSpriteList() {
        _listOfSprites.removeAll()
        
        let list = FileManager.filesInDocuments(folder: _project + fileExtension).sorted()
        
        for file in list {
            if file.contains(".sprite") {
                let str = file.substring(toIndex: 4)
                
                if let number = Int(str) {
                    _listOfSprites.append(number)
                }
            }
        }
    }

    func pathForSpriteFile(number: Int) -> String {
        let path = FileManager.folderInDocuments(_project + fileExtension).path + "/" + String(format: "%04d.sprite", number)
        return path
    }

    func pathForPaletteFile(number: Int) -> String {
        let path = FileManager.folderInDocuments(_project + fileExtension).path + "/" + String(format: "%04d.pal", number)
        return path
    }

    func pathForProjectPaletteFile() -> String {
        let path = FileManager.folderInDocuments(_project + fileExtension).path + "/project.pal"
        return path
    }

    // -------------------------------------------------------------------------
    // MARK: - Palette handling

    func loadPaletteForCurrentSprite() {
        var path = pathForPaletteFile(number: _spriteNumber)

        _usesProjectPalette = false
        
        if !FileManager.exists(path: path) {
            path = pathForProjectPaletteFile()
            _usesProjectPalette = true
            
            rbInfo("Sprite has no palette, load project palette instead")
        }
        
        _palette.removeAll()
        
        if let content = String.load(path: path) {
            let palette = content.components(separatedBy: "\n")

            for hex in palette {
                if hex.count == 8 {
                    let hex = hex.substring(fromIndex: 2)
                    _palette.append(OSColor(hex: hex))
                }
            }
            
            rbDebug("\(_palette.count) entries read in palette")
        }
        
        notify(with: .paletteChanged, sender: self)
    }
    
    func addPalette() {
        // Copy palette template to destination
        if let fromPath = Bundle.main.path(forResource: "zxnext256", ofType: "pal") {
            let toPath = pathForProjectPaletteFile()
            
            if !FileManager.copy(from:fromPath, to:toPath, overwrite: true) {
                return
            }
            
            loadPaletteForCurrentSprite()
        }
        else {
            rbError("Cant create palette file in project")
            return
        }

        notify(with: .paletteChanged, sender: self)
    }

    private func savePalette(_ palette: [RBColor], spriteNumber: Int?) {
        var content = ""
        for color in palette {
            let r = String(format:"%02X", color.r)
            let g = String(format:"%02X", color.g)
            let b = String(format:"%02X", color.b)
            
            if content.length == 0 {
                let hex = "FF\(r)\(g)\(b)"
                content = hex
            }
            else {
                let hex = "\nFF\(r)\(g)\(b)"
                content = content + hex
            }
        }
        
        let count = 256 - palette.count
        if count > 0 {
            for _ in 1...count {
                let hex = "\nFF000000"
                content = content + hex
            }
        }
        
        // Last entry is transparency color
        let color = _palette[_transColorIndex]
        let r = String(format:"%02X", Int(color.red()*255))
        let g = String(format:"%02X", Int(color.green()*255))
        let b = String(format:"%02X", Int(color.blue()*255))
        let hex = "FF\(r)\(g)\(b)"
        content = content + hex
        
        if let number = spriteNumber {
            content = "; Palette for sprite \(number)\n" + content

            let path = pathForPaletteFile(number: number)
            content.save(path: path)
        }
        else {
            content = "; Palette of project\n" + content

            let path = pathForProjectPaletteFile()
            content.save(path: path)
        }
    }

    private func saveCurrentPalette() {
        // TODO: Internally the palette should use color RBColor!!!!
        // Change also in Palette viewer
        
        if _usesProjectPalette {
        }
        else {
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Import handling

    func addSprite(data: [Int], palette: [RBColor]? = nil) {
        var newNumber = 0
        
        for number in _listOfSprites {
            if number > newNumber {
                newNumber = number
            }
        }

        notify(with: .currentSpriteWillClose, sender: self)

        _spriteNumber = newNumber + 1

        // Save palette
        if palette != nil {
            savePalette(palette!, spriteNumber: _spriteNumber)
        }

        // Save sprite
        saveSpriteData(data)
        
        refreshSpriteList()
        
        loadPaletteForCurrentSprite()
        
        notify(with: .currentSpriteChanged, sender: self)
    }

    private func findColorInPalette(color: RBColor, palette: [RBColor]) -> UInt8? {
        if palette.count == 0 {
            return nil
        }
        
        for index in 0..<palette.count-1 {
            let entry = palette[index]
            if entry.r == color.r && entry.g == color.g && entry.b == color.b {
                return UInt8(index)
            }
        }
        
        return nil
    }

    public func importImage(path: String) {
        let image = RBBitmap()
        image.load(path: path)

        var palette: [RBColor] = []
        var data: [Int] = []

        for v in 0...Int(image.width-1) {
            for h in 0...Int(image.height-1) {
                if let color = image.getPixelColor(x: h, y: v) {
                    // Find color in palette
                    if let index = findColorInPalette(color: color, palette: palette) {
                        data.append(Int(index))
                    }
                    else {
                        palette.append(color)
                        data.append(palette.count-1)
                    }
                }
            }
        }
        
        if palette.count > 256 {
            rbWarning("Too much colors in this image. Not possible to create a 256-color palette")
        }
        
        addSprite(data: data, palette: palette)
    }

    // -------------------------------------------------------------------------
    // MARK: - Sprite handling

    func loadSprite(_ number: Int) {
        _spriteNumber = number
        
        loadPaletteForCurrentSprite()
        
        notify(with: .currentSpriteChanged, sender: self)
    }

    func loadSpriteData(number: Int) -> [Int] {
        var data: [Int] = []
        let path = ProjectManager.shared.pathForSpriteFile(number: number)

        if let content = String.load(path: path) {
            let numbers = content.components(separatedBy: ",")
            
            for entry in numbers {
                if entry.count > 0 {
                    if entry[0] == "\n" {
                        if let index = Int(entry.substring(fromIndex: 1)) {
                            data.append(index)
                        }
                    }
                    else {
                        if let index = Int(entry) {
                            data.append(index)
                        }
                    }
                }
            }
            
            // TODO: Remove last \n
            if data.count < 256 {
                data.append(4)
            }
        }
        
        return data
    }

    func saveSpriteData(_ data: [Int]) {
        var content = ""
        for entry in data {
            if content.length == 0 {
                content = "\(entry)"
            }
            else  {
                content = content + ",\(entry)"
            }
        }

        do {
            let path = pathOfCurrentSprite
            try content.write(toFile: path, atomically: false, encoding: .utf8)
            
            rbInfo("Sprite \(_spriteNumber) saved")
        }
        catch {
            rbError("Error save sprite \(_spriteNumber)")
        }
    }

    func addNewSprite(example: Bool) {
        var newNumber = 0
        
        for number in _listOfSprites {
            if number > newNumber {
                newNumber = number
            }
        }

        notify(with: .currentSpriteWillClose, sender: self)

        _spriteNumber = newNumber + 1

        // Copy sprite template to destination
        if example {
            if let fromPath = Bundle.main.path(forResource: "sprite", ofType: "txt") {
                let toPath = pathForSpriteFile(number: _spriteNumber)
                
                if !FileManager.copy(from:fromPath, to:toPath, overwrite: true) {
                    return
                }
            }
            else {
                rbError("Cant create new sprite file in project")
                return
            }
        }
        else {
            // Create empty sprite
            var data: [Int] = []
            for _ in 1...256 {
                data.append(_transColorIndex)
            }
            
            // Save
            saveSpriteData(data)
        }
        
        refreshSpriteList()
        
        notify(with: .currentSpriteChanged, sender: self)
    }
    
    func prevSprite() {
        var number = _spriteNumber - 1
        if number < 1 {
            number = _listOfSprites.count
        }
        
        if number == _spriteNumber {
            return
        }

        notify(with: .currentSpriteWillClose, sender: self)

        _spriteNumber = number
        loadSprite(_spriteNumber)
    }
    
    func nextSprite() {
        var number = _spriteNumber + 1
        if number > _listOfSprites.count {
            number = 1
        }
        
        if number == _spriteNumber {
            return
        }

        notify(with: .currentSpriteWillClose, sender: self)

        _spriteNumber = number
        loadSprite(_spriteNumber)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Project handling

    func createProject(_ name: String) {
        _project = name
        
        _ = FileManager.createFolderInDocuments(name + fileExtension)
        
        addPalette()
    }
    
    func loadProject(_ name: String) {
        _project = name
        
        refreshSpriteList()
        
        notify(with: .currentProjectChanged, sender: self)
        
        if _listOfSprites.count > 0 {
            loadSprite(_listOfSprites.first!)
        }
        else {
            addNewSprite(example: true)
        }
    }
   
    // -------------------------------------------------------------------------
    // MARK: - Singleton support
    
    static let shared : ProjectManager = {
        let instance = ProjectManager()
        return instance
    }()
    
}
