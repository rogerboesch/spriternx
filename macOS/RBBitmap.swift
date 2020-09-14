
import Foundation
import CoreGraphics
import AppKit

struct RBColor {
    var r: UInt8 = 0
    var g: UInt8 = 0
    var b: UInt8 = 0
}

class RBBitmap {
    private var _colors: [RBColor] = []
    private var _width: Int = 0
    private var _height: Int = 0
    
    var width: Int {
        return _width
    }
    
    var height: Int {
        return _height
    }

    @discardableResult
    func load(path: String) -> Bool {
        guard let image = OSImage(contentsOfFile: path) else { return false }

        _width = Int(image.size.width)
        _height = Int(image.size.height)

        image.lockFocus()
        
        for h in 0..<_height {
            for w in 0..<_width {
                if let pixelColor = NSReadPixel(NSMakePoint(CGFloat(w), CGFloat(h))) {
                    let r = UInt8(pixelColor.red()*255)
                    let g = UInt8(pixelColor.green()*255)
                    let b = UInt8(pixelColor.blue()*255)
                    let color = RBColor(r: r, g: g, b: b)
                    
                    _colors.append(color)
                }
                else {
                    _colors.removeAll()
                    return false
                }
            }
        }

        image.unlockFocus()
        
        if _colors.count != _width*_height {
            rbError("Wrong number of colors")
            _colors.removeAll()
            
             return false
        }
        
        rbInfo("Image file loaded (\(_width)x\(_height)): \(path)")

        return true
    }
    
    @discardableResult
    func loadFromBundle(filename: String, ext: String) -> Bool {
        if let path = Bundle.main.path(forResource: filename, ofType: ext) {
            return load(path: path)
        }
        
        return false
    }

    func getPixelColor(x: Int, y: Int) -> RBColor? {
        guard _colors.count > 0 else { return nil }

        let index = y * _width + x
        if index >= _colors.count {
            return nil
        }
        
        return _colors[index]
    }
}

class RBByteArray {
    private var _byteArray : [UInt8]
    private var _arrayIndex = 0
    private var _arraySize = 0
    
    public init(_ byteArray : [UInt8]) {
        _byteArray = byteArray;
        _arraySize = _byteArray.count
    }

    public init(_ data : Data) {
        _byteArray = [UInt8](data)
        _arraySize = _byteArray.count
    }

    // Property to provide read-only access to the current array index value.
    public var arrayIndex : Int {
        get { return _arrayIndex }
    }

    public func setIndex(_ index: Int) {
        guard index < _arraySize else { return }
        
        _arrayIndex = index
    }
    
    // Calculate how many bytes are left in the byte array, i.e., from the index point to the end of the byte array.
    public var bytesLeft : Int {
        get { return _byteArray.count - _arrayIndex }
    }

    // Get a single byte from the byte array.
    public func getUInt8() -> UInt8 {
        let returnValue = _byteArray[_arrayIndex]
        _arrayIndex += 1
        
        return returnValue
    }
    
    public func getUInt8(index: Int) -> UInt8 {
        let returnValue = _byteArray[index]
        
        return returnValue
    }

    // Get an Int16 from two bytes in the byte array (little-endian).
    public func getInt16() -> Int16 {
        let returnValue = Int16(bitPattern: getUInt16())
        _arrayIndex += 2

        return returnValue
    }

    // Get a UInt16 from two bytes in the byte array (little-endian).
    public func getUInt16() -> UInt16 {
        let returnValue = UInt16(_byteArray[_arrayIndex]) | UInt16(_byteArray[_arrayIndex + 1]) << 8
        _arrayIndex += 2
        
        return returnValue
    }

    // Get a UInt from three bytes in the byte array (little-endian).
    public func getUInt24() -> UInt {
        let returnValue = UInt(_byteArray[_arrayIndex]) |
                          UInt(_byteArray[_arrayIndex + 1]) << 8 |
                          UInt(_byteArray[_arrayIndex + 2]) << 16
        _arrayIndex += 3
        
        return returnValue
    }

    // Get an Int32 from four bytes in the byte array (little-endian).
    public func getInt32() -> Int32 {
        let returnValue = Int32(bitPattern: getUInt32())
        _arrayIndex += 4
        
        return returnValue
    }

    // Method to get a UInt32 from four bytes in the byte array (little-endian).
    public func getUInt32() -> UInt32 {
        let returnValue = UInt32(_byteArray[_arrayIndex]) |
                          UInt32(_byteArray[_arrayIndex + 1]) << 8 |
                          UInt32(_byteArray[_arrayIndex + 2]) << 16 |
                          UInt32(_byteArray[_arrayIndex + 3]) << 24
        _arrayIndex += 4
        
        return returnValue
    }

    // Get an Int64 from eight bytes in the byte array (little-endian).
    public func getInt64() -> Int64 {
        let returnValue = Int64(bitPattern: getUInt64())
        _arrayIndex += 8
        
        return returnValue
    }

    // Get a UInt64 from eight bytes in the byte array (little-endian).
    public func getUInt64() -> UInt64 {
        let returnValue = UInt64(_byteArray[_arrayIndex]) |
                          UInt64(_byteArray[_arrayIndex + 1]) << 8 |
                          UInt64(_byteArray[_arrayIndex + 2]) << 16 |
                          UInt64(_byteArray[_arrayIndex + 3]) << 24 |
                          UInt64(_byteArray[_arrayIndex + 4]) << 32 |
                          UInt64(_byteArray[_arrayIndex + 5]) << 40 |
                          UInt64(_byteArray[_arrayIndex + 6]) << 48 |
                          UInt64(_byteArray[_arrayIndex + 7]) << 56
        _arrayIndex += 8
        return returnValue
    }
}

public enum PixelFormat {
    case abgr
    case argb
    case bgra
    case rgba
}

extension CGBitmapInfo {
    public static var byteOrder16Host: CGBitmapInfo {
        return CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) ? .byteOrder16Little : .byteOrder16Big
    }

    public static var byteOrder32Host: CGBitmapInfo {
        return CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) ? .byteOrder32Little : .byteOrder32Big
    }
}

extension CGBitmapInfo {
    public var pixelFormat: PixelFormat? {

        // AlphaFirst – the alpha channel is next to the red channel, argb and bgra are both alpha first formats.
        // AlphaLast – the alpha channel is next to the blue channel, rgba and abgr are both alpha last formats.
        // LittleEndian – blue comes before red, bgra and abgr are little endian formats.
        // Little endian ordered pixels are BGR (BGRX, XBGR, BGRA, ABGR, BGR).
        // BigEndian – red comes before blue, argb and rgba are big endian formats.
        // Big endian ordered pixels are RGB (XRGB, RGBX, ARGB, RGBA, RGB).

        let alphaInfo: CGImageAlphaInfo? = CGImageAlphaInfo(rawValue: self.rawValue & type(of: self).alphaInfoMask.rawValue)
        let alphaFirst: Bool = alphaInfo == .premultipliedFirst || alphaInfo == .first || alphaInfo == .noneSkipFirst
        let alphaLast: Bool = alphaInfo == .premultipliedLast || alphaInfo == .last || alphaInfo == .noneSkipLast
        let endianLittle: Bool = self.contains(.byteOrder32Little)

        // This is slippery… while byte order host returns little endian, default bytes are stored in big endian
        // format. Here we just assume if no byte order is given, then simple RGB is used, aka big endian, though…

        if alphaFirst && endianLittle {
            return .bgra
        }
        else if alphaFirst {
            return .argb
        }
        else if alphaLast && endianLittle {
            return .abgr
        }
        else if alphaLast {
            return .rgba
        }
        else {
            return nil
        }
    }
}
