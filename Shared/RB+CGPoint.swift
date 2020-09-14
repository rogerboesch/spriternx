//
//  RB+CGPoint.swift
//  CGRect extensions
//
//  Created by Roger Boesch on 01/01/16.
//  Copyright © 2016 Roger Boesch All rights reserved.
//

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

// -----------------------------------------------------------------------------
// MARK: - Make a CGPoint

extension CGPoint {
    
    static func make(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    static func make(_ x: Int, _ y: Int) -> CGPoint {
        return CGPoint(x: x, y: y)
    }
    
}

// -----------------------------------------------------------------------------

public extension CGPoint {
    
    // -------------------------------------------------------------------------
    
    init(vector: CGVector) {
        self.init(x: vector.dx, y: vector.dy)
    }
    
    // ------------------------------------------------------------------------------
    
    init(angle: CGFloat) {
        self.init(x: cos(angle), y: sin(angle))
    }
    
    // ------------------------------------------------------------------------------
    
    mutating func offset(_ dx: CGFloat, dy: CGFloat) -> CGPoint {
        x += dx
        y += dy
        
        return self
    }
    
    // ------------------------------------------------------------------------------
    
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    // ------------------------------------------------------------------------------
    
    func lengthSquared() -> CGFloat {
        return x*x + y*y
    }
    
    // ------------------------------------------------------------------------------
    
    func normalized() -> CGPoint {
        let len = length()
        
        return len>0 ? self / len : CGPoint.zero
    }
    
    // ------------------------------------------------------------------------------
    
    mutating func normalize() -> CGPoint {
        self = normalized()
        
        return self
    }
    
    // ------------------------------------------------------------------------------
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
        return (self - point).length()
    }
    
    // ------------------------------------------------------------------------------
    
    var angle: CGFloat {
        return atan2(y, x)
    }
    
    // ------------------------------------------------------------------------------
    
}

// ------------------------------------------------------------------------------

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

// ------------------------------------------------------------------------------

public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

// ------------------------------------------------------------------------------

public func + (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
}

// ------------------------------------------------------------------------------

public func += (left: inout CGPoint, right: CGVector) {
    left = left + right
}

// ------------------------------------------------------------------------------

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

// ------------------------------------------------------------------------------

public func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

// ------------------------------------------------------------------------------

public func - (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
}

// ------------------------------------------------------------------------------

public func -= (left: inout CGPoint, right: CGVector) {
    left = left - right
}

// ------------------------------------------------------------------------------

public func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

// ------------------------------------------------------------------------------

public func *= (left: inout CGPoint, right: CGPoint) {
    left = left * right
}

// ------------------------------------------------------------------------------

public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

// ------------------------------------------------------------------------------

public func *= (point: inout CGPoint, scalar: CGFloat) {
    point = point * scalar
}

// ------------------------------------------------------------------------------

public func * (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x * right.dx, y: left.y * right.dy)
}

// ------------------------------------------------------------------------------

public func *= (left: inout CGPoint, right: CGVector) {
    left = left * right
}

// ------------------------------------------------------------------------------

public func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

// ------------------------------------------------------------------------------

public func /= (left: inout CGPoint, right: CGPoint) {
    left = left / right
}

// ------------------------------------------------------------------------------

public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

// ------------------------------------------------------------------------------

public func /= (point: inout CGPoint, scalar: CGFloat) {
    point = point / scalar
}

// ------------------------------------------------------------------------------

public func / (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x / right.dx, y: left.y / right.dy)
}

// ------------------------------------------------------------------------------

public func /= (left: inout CGPoint, right: CGVector) {
    left = left / right
}

// ------------------------------------------------------------------------------

public func lerp(_ start: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
    return CGPoint(x: start.x + (end.x - start.x)*t, y: start.y + (end.y - start.y)*t)
}

// ------------------------------------------------------------------------------
