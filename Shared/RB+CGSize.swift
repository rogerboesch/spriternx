//
//  RB+CGSize.swift
//  CGSize extensions
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
// MARK: - Make a CGSize

extension CGSize {
    
    static func make(_ w: CGFloat, _ h: CGFloat) -> CGSize {
        return CGSize(width: w, height: h)
    }
    
}

// -----------------------------------------------------------------------------
