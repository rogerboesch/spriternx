
import AppKit

extension NSImage {
    
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    
    func writeAsPng(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    class func load(from url: URL) -> NSImage? {
        return NSImage(contentsOf: url)
    }
}

extension NSImage {

    func resize(w: Int, h: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        self.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, self.size.width, self.size.height), operation: NSCompositingOperation.copy, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        
        return NSImage(data: newImage.tiffRepresentation!)!
    }
}

extension NSImage {
    
    class func slice(from image: NSImage, rect: NSRect) -> NSImage {
        let targetRect = NSMakeRect(0, 0, rect.size.width, rect.size.height);
        let result = NSImage(size: targetRect.size)
        
        result.lockFocus()
        image.draw(in: targetRect, from: rect, operation: .copy, fraction: 1.0)
        result.unlockFocus()
        
        return result
    }
    
    func slices(_ width: CGFloat, _ height: CGFloat) -> [NSImage] {
        let xCount = Int(self.size.width / width)
        let yCount = Int(self.size.height / height)
        
        var slices: [NSImage] = []
        
        for y in 0...yCount-1 {
            for x in 0...xCount-1 {
                let rect = CGRect.make(CGFloat(x)*width, self.size.height-CGFloat(y+1)*height, width, height)
                let sliceImage = NSImage.slice(from: self, rect: rect)
                slices.append(sliceImage)
            }
        }
        
        return slices
    }
}

extension NSImage {

    convenience init(color: NSColor, size: NSSize) {
        self.init(size: size)
        lockFocus()
        color.drawSwatch(in: NSRect(origin: .zero, size: size))
        unlockFocus()
    }
    
}

