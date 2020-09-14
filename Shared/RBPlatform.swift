//
//  RBPlatform.swift
//  iOS/macOS Platform definitions
//
//  Created by Roger Boesch on 13/01/17.
//  Copyright © 2017 Roger Boesch. All rights reserved.
//

import SceneKit

struct GameKeys {
    static var left: Int = 123
    static var right: Int = 124
    static var down: Int = 125
    static var up: Int = 126
    static var space: Int = 49
    static var enter: Int = 36
    static var esc: Int = 53
    static var backspace: Int = 51
    static var tab: Int = 48

    static var a: Int = 0
    static var b: Int = 11
    static var c: Int = 8
    static var d: Int = 2
    static var e: Int = 14
    static var f: Int = 3
    static var g: Int = 5
    static var h: Int = 4
    static var i: Int = 34
    static var j: Int = 38
    static var k: Int = 40
    static var l: Int = 37
    static var m: Int = 46
    static var n: Int = 45
    static var o: Int = 31
    static var p: Int = 35
    static var q: Int = 12
    static var r: Int = 15
    static var s: Int = 1
    static var t: Int = 17
    static var u: Int = 32
    static var v: Int = 9
    static var w: Int = 13
    static var x: Int = 7
    static var y: Int = 16
    static var z: Int = 6
    
    static var zero: Int = 29
    static var one: Int = 18
    static var two: Int = 19
    static var three: Int = 20
    static var four: Int = 21
    static var five: Int = 23
    static var six: Int = 22
    static var seven: Int = 26
    static var eight: Int = 28
    static var nine: Int = 25
}

#if os(watchOS)
    import WatchKit
#endif

#if os(macOS)
    import AppKit
    
    public typealias OSRect = NSRect
    public typealias OSPoint = NSPoint
    public typealias OSColor = NSColor
    public typealias OSImage = NSImage
    public typealias OSFloat = CGFloat
    public typealias OSView = NSView
    public typealias OSEvent = NSEvent
    public typealias OSFont = NSFont
    public typealias OSVector3 = SCNVector3

    extension NSImage {
        
        class func getImage(named name: String, folder: String? = nil) -> NSImage? {
            if folder == nil {
                return NSImage(named: name)
            }
            else {
                let bundle = Bundle.main
                if let path = bundle.path(forResource: name, ofType: "png", inDirectory: folder) {
                    let image = NSImage(contentsOfFile: path)
                    return image
                }
                
                return nil
            }
        }
        
        class func getImage(path: String) -> NSImage? {
            let image = NSImage(contentsOfFile: path)
            return image
        }

    }

#else
    public typealias OSRect = CGRect
    public typealias OSPoint = CGPoint
    public typealias OSColor = UIColor
    public typealias OSImage = UIImage
    public typealias OSFloat = Float
    public typealias OSView = UIView
    public typealias OSEvent = UITouch
    public typealias OSFont = UIFont
    public typealias OSVector3 = SCNVector3

    extension UIImage {
        
        class func getImage(named name: String, folder: String? = nil) -> UIImage? {
            if folder == nil {
                return UIImage(named: name)
            }
            else {
                let bundle = Bundle.main
                if let path = bundle.path(forResource: name, ofType: "png", inDirectory: folder) {
                    let image = UIImage(contentsOfFile: path)
                
                    return image
                }
                
                return nil
            }
        }

        class func getImage(path: String) -> UIImage? {
            return nil
        }

    }

#endif

#if os(iOS)

    func SCNDeviceOrientationIsLandscape() -> Bool {
        if UIDevice.current.orientation.isLandscape {
            return true
        }
        
        return false
    }

#endif

#if os(tvOS)

    func SCNDeviceOrientationIsLandscape() -> Bool {
        return true
    }

#endif




