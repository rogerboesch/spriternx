//
//  RBMath.swift
//  Math shortcuts
//
//  Created by Roger Boesch on 11.01.18.
//  Copyright © 2018 Roger Boesch. All rights reserved.
//

import Foundation

let pi = OSFloat(Double.pi)

extension Int {
    
    func toRadians() -> OSFloat {
        return OSFloat(self) * OSFloat(Double.pi) / 180.0
    }
    
    func toDegrees() -> OSFloat {
        return OSFloat(self) * 180.0 / OSFloat(Double.pi)
    }
    
}

extension Double {
    
    func toRadians() -> OSFloat {
        return OSFloat(self) * OSFloat(Double.pi) / 180.0
    }
    
    func toDegrees() -> OSFloat {
        return OSFloat(self) * 180.0 / OSFloat(Double.pi)
    }
    
}

extension Float {
    
    func round(nearest: Float) -> Float {
        let n = 1/nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }
    
    func floor(nearest: Float) -> Float {
        let intDiv = Float(Int(self / nearest))
        return intDiv * nearest
    }
    
}

extension OSFloat {
    
    func toRadians() -> OSFloat {
        return OSFloat(self) * OSFloat(Double.pi) / 180.0
    }
    
    func toDegrees() -> OSFloat {
        return OSFloat(self) * 180.0 / OSFloat(Double.pi)
    }
    
}

