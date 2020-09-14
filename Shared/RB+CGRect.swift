//
//  RB+CGRect.swift
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
// MARK: - Chaning

extension CGRect {
    
    func replaceWidth(_ width: CGFloat) -> CGRect {
        var rect = self
        rect.size.width = width
        
        return rect
    }
    
    func changeBy(_ left: CGFloat, _ right: CGFloat, _ top: CGFloat, _ bottom: CGFloat) -> CGRect {
        let rect = CGRect.make(self.origin.x+left, self.origin.y+top,
                              self.size.width-left-right, self.size.height-top-bottom)
        return rect
    }

    func moveDown(_ offset: CGFloat) -> CGRect {
        var rect = self
        rect.origin.y += offset
        
        return rect
    }

}

// -----------------------------------------------------------------------------
// MARK: - Make a CGRect

extension CGRect {
    
    static func make(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
}

// -----------------------------------------------------------------------------
