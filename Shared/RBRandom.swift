//
//  RBRandom.swift
//  Random number extensions
//
//  Created by Roger Boesch on 13/01/17.
//  Copyright © 2017 Roger Boesch. All rights reserved.
//

import Foundation
import GameKit

extension Int {
    static func random(maxValue: Int) -> Int {
        let rand = Int(arc4random_uniform(UInt32(maxValue)))
        return rand
    }
}

class RBRandom {
    private let source = GKMersenneTwisterRandomSource()
    
    // -------------------------------------------------------------------------
    // MARK: - Get random numbers
    
    class func boolean() -> Bool {
        if RBRandom.shared.integer(0, 1) == 1 {
            return true
        }
        
        return false
    }

    // -------------------------------------------------------------------------

    class func integer(_ from: Int, _ to: Int) -> Int {
        return RBRandom.shared.integer(from, to)
    }

    // -------------------------------------------------------------------------
    
    class func timeInterval(_ from: Int, _ to: Int) -> TimeInterval {
        return TimeInterval(RBRandom.shared.integer(from, to))
    }
    
    // -------------------------------------------------------------------------
    
    class func float(_ from: OSFloat, _ to: OSFloat) -> OSFloat {
        return OSFloat(RBRandom.shared.integer(Int(from), Int(to)))
    }
    
    // -------------------------------------------------------------------------
    
    class func cgFloat(_ from: CGFloat, _ to: CGFloat) -> CGFloat {
        return CGFloat(RBRandom.shared.integer(Int(from), Int(to)))
    }

    // -------------------------------------------------------------------------
    
    private func integer(_ from: Int, _ to: Int) -> Int {
        let rd = GKRandomDistribution(randomSource: self.source, lowestValue: from, highestValue: to)
        let number = rd.nextInt()
        
        return number
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Initialisation
    
    init() {
        source.seed = UInt64(CFAbsoluteTimeGetCurrent())
    }
    
    // -------------------------------------------------------------------------
    
    private static let shared : RBRandom = {
        let instance = RBRandom()
        return instance
    }()
    
    // -------------------------------------------------------------------------

}

