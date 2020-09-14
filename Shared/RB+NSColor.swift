import Cocoa

// -----------------------------------------------------------------------------
// MARK: - Hex support

extension NSColor {
    
    public convenience init(hex: String) {
        var str = hex
        
        if str.hasPrefix("#") {
            str = str.substring(fromIndex: 1)
        }
        
        if (str.count == 6) {
            str = "\(str)ff"
        }
        
        if str.count  == 8 {
            let scanner = Scanner(string: String(str))
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                let r = (hexNumber & 0xff000000) >> 24
                let g = (hexNumber & 0x00ff0000) >> 16
                let b = (hexNumber & 0x0000ff00) >> 8
                let a = (hexNumber & 0x000000ff)
                
                self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0)
                return
            }
        }
        
        self.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    var hex: String {
        let components = self.cgColor.components
        
        let red = Float((components?[0])!)
        let green = Float((components?[1])!)
        
        if components!.count > 2 {
            let blue = Float((components?[2])!)
            return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
        }
        else {
            return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(red * 255), lroundf(red * 255))
        }
    }
    
}

// -----------------------------------------------------------------------------
// MARK: - Parts support

extension NSColor {

    public convenience init(_ r: Int, _ g: Int, _ b: Int) {
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
    }
    
    // -------------------------------------------------------------------------
    
    func red() -> CGFloat {
        return self.cgColor.components![0]
    }
    
    // -------------------------------------------------------------------------
    
    func green() -> CGFloat {
        return self.cgColor.components![1]
    }
    
    // -------------------------------------------------------------------------
    
    func blue() -> CGFloat {
        return self.cgColor.components![2]
    }
    
    // -------------------------------------------------------------------------
    
    func alpha() -> CGFloat {
        return self.cgColor.components![3]
    }
    
    // -------------------------------------------------------------------------
    
    func setAlpha(alpha: CGFloat) -> NSColor {
        return NSColor(red: self.red(), green: self.green(), blue: self.blue(), alpha: alpha)
    }
}

// -----------------------------------------------------------------------------
// MARK: - Text extensions

extension NSColor {
    func toString() -> String {
        let r = Int(self.red() * 255.0)
        let g = Int(self.green() * 255.0)
        let b = Int(self.blue() * 255.0)
        let a = Int(self.alpha() * 255.0)
        
        let str = "\(r)|\(g)|\(b)|\(a)"
        return str
    }

    public convenience init(fromString: String) {
        let list = fromString.components(separatedBy: "|")
        if (list.count != 4) {
            self.init()
        }
        else {
            var num = Double(list[0])!
            let r = CGFloat(num / 255.0)
            
            num = Double(list[1])!
            let g = CGFloat(num / 255.0)
            
            num = Double(list[2])!
            let b = CGFloat(num / 255.0)
            
            num = Double(list[3])!
            let a = CGFloat(num / 255.0)


            self.init(red: r, green: g, blue: b, alpha: a)
        }
    }
    
}

// -----------------------------------------------------------------------------
// MARK: - Helpers

extension NSColor {
    
    override open var description: String {
        get {
            return "\(self.hex) (r:\(red()*255) g:\(green()*255) b:\(blue()*255) a:\(alpha()))"
        }
    }
    
    public static func random(list: [NSColor]) -> NSColor {
        let maxValue = list.count
        let rand = RBRandom.integer(0, maxValue-1)
        
        return list[rand]
    }
    
}

public extension NSColor {

    /// Adjust color based on saturation
    ///
    /// - Parameter minSaturation: The minimun saturation value
    /// - Returns: The adjusted color
    func color(minSaturation: CGFloat) -> NSColor {
        var (hue, saturation, brightness, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return saturation < minSaturation
            ? NSColor(hue: hue, saturation: minSaturation, brightness: brightness, alpha: alpha)
            : self
    }
    
    /// Convenient method to change alpha value
    ///
    /// - Parameter value: The alpha value
    /// - Returns: The alpha adjusted color
    func alpha(_ value: CGFloat) -> NSColor {
        return withAlphaComponent(value)
    }
}

// MARK: - Helpers
public extension NSColor {
    
    internal func rgbComponents() -> [CGFloat] {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return [r, g, b]
    }
    
    var isDark: Bool {
        let RGB = rgbComponents()
        return (0.2126 * RGB[0] + 0.7152 * RGB[1] + 0.0722 * RGB[2]) < 0.5
    }
    
    var isBlackOrWhite: Bool {
        let RGB = rgbComponents()
        return (RGB[0] > 0.91 && RGB[1] > 0.91 && RGB[2] > 0.91) || (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
    }
    
    var isBlack: Bool {
        let RGB = rgbComponents()
        return (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
    }
    
    var isWhite: Bool {
        let RGB = rgbComponents()
        return (RGB[0] > 0.91 && RGB[1] > 0.91 && RGB[2] > 0.91)
    }
    
    func isDistinct(from color: NSColor) -> Bool {
        let bg = rgbComponents()
        let fg = color.rgbComponents()
        let threshold: CGFloat = 0.25
        var result = false
        
        if abs(bg[0] - fg[0]) > threshold || abs(bg[1] - fg[1]) > threshold || abs(bg[2] - fg[2]) > threshold {
            if abs(bg[0] - bg[1]) < 0.03 && abs(bg[0] - bg[2]) < 0.03 {
                if abs(fg[0] - fg[1]) < 0.03 && abs(fg[0] - fg[2]) < 0.03 {
                    result = false
                }
            }
            result = true
        }
        
        return result
    }
    
    func isContrasting(with color: NSColor) -> Bool {
        let bg = rgbComponents()
        let fg = color.rgbComponents()
        
        let bgLum = 0.2126 * bg[0] + 0.7152 * bg[1] + 0.0722 * bg[2]
        let fgLum = 0.2126 * fg[0] + 0.7152 * fg[1] + 0.0722 * fg[2]
        let contrast = bgLum > fgLum
            ? (bgLum + 0.05) / (fgLum + 0.05)
            : (fgLum + 0.05) / (bgLum + 0.05)
        
        return 1.6 < contrast
    }
    
}

public extension NSColor {
    
    var redComponent: CGFloat {
        var r: CGFloat = 0
        self.getRed(&r, green: nil , blue: nil, alpha: nil)
        return r
    }
    
    var greenComponent: CGFloat {
        var g: CGFloat = 0
        self.getRed(nil, green: &g , blue: nil, alpha: nil)
        return g
    }
    
    var blueComponent: CGFloat {
        var b: CGFloat = 0
        self.getRed(nil, green: nil , blue: &b, alpha: nil)
        return b
    }
    
    var alphaComponent: CGFloat {
        var a: CGFloat = 0
        self.getRed(nil, green: nil , blue: nil, alpha: &a)
        return a
    }
    
    var hueComponent: CGFloat {
        var hue: CGFloat = 0
        getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }
    
    var saturationComponent: CGFloat {
        var saturation: CGFloat = 0
        getHue(nil, saturation: &saturation, brightness: nil, alpha: nil)
        return saturation
    }
    
    var brightnessComponent: CGFloat {
        var brightness: CGFloat = 0
        getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        return brightness
    }
}

public extension NSColor {
    
    /**adds hue, saturation, and brightness to the HSB components of this color (self)*/
    func add(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) -> NSColor {
        var (oldHue, oldSat, oldBright, oldAlpha) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        getHue(&oldHue, saturation: &oldSat, brightness: &oldBright, alpha: &oldAlpha)
        
        // make sure new values doesn't overflow
        var newHue = oldHue + hue
        while newHue < 0.0 { newHue += 1.0 }
        while newHue > 1.0 { newHue -= 1.0 }
        
        let newBright: CGFloat = max(min(oldBright + brightness, 1.0), 0)
        let newSat: CGFloat = max(min(oldSat + saturation, 1.0), 0)
        let newAlpha: CGFloat = max(min(oldAlpha + alpha, 1.0), 0)
        
        return NSColor(hue: newHue, saturation: newSat, brightness: newBright, alpha: newAlpha)
    }
    
    /**adds red, green, and blue to the RGB components of this color (self)*/
    func add(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> NSColor {
        var (oldRed, oldGreen, oldBlue, oldAlpha) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        getRed(&oldRed, green: &oldGreen, blue: &oldBlue, alpha: &oldAlpha)
        // make sure new values doesn't overflow
        let newRed: CGFloat = max(min(oldRed + red, 1.0), 0)
        let newGreen: CGFloat = max(min(oldGreen + green, 1.0), 0)
        let newBlue: CGFloat = max(min(oldBlue + blue, 1.0), 0)
        let newAlpha: CGFloat = max(min(oldAlpha + alpha, 1.0), 0)
        
        return NSColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }
    
    func add(hsb color: NSColor) -> NSColor {
        var (h,s,b,a) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return self.add(hue: h, saturation: s, brightness: b, alpha: 0)
    }
    
    func add(rgb color: NSColor) -> NSColor {
        return self.add(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 0)
    }
    
    func add(hsba color: NSColor) -> NSColor {
        var (h,s,b,a) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return self.add(hue: h, saturation: s, brightness: b, alpha: a)
    }
    
    /**adds the rgb components of two colors*/
    func add(rgba color: NSColor) -> NSColor {
        return self.add(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: color.alphaComponent)
    }
}
