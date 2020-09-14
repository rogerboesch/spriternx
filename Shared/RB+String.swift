//
//  RB+String.swift
//  String extensions
//
//  Created by Roger Boesch on 01/01/16.
//  Copyright © 2016 Roger Boesch All rights reserved.
//

import Foundation

// -----------------------------------------------------------------------------
// MARK: - subscript

extension String {
    
    var length: Int {
        return self.count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
}

// -----------------------------------------------------------------------------
// MARK: - 1st character uppercase

extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
}

// -----------------------------------------------------------------------------
// MARK: - Fill-up string

extension String {

    public static func fill(character: String, count: Int) ->String {
        var str = ""

        for _ in 0...count {
            str = str + character
        }
        
        return str
    }
    
}

// -----------------------------------------------------------------------------
// MARK: - Trim string

extension String {
    
    public func trim() ->String {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed
    }
    
}

// -----------------------------------------------------------------------------
// MARK: - Localisation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

// -----------------------------------------------------------------------------
// MARK: - Persistency

extension String {
    
    @discardableResult
    func save(path: String) -> Bool {
        let fileURL = URL(fileURLWithPath: path)
        
        do {
            try self.write(to: fileURL, atomically: false, encoding: .utf8)
            
            rbDebug("Save string at '\(fileURL)'")
            
            return true
        }
        catch let error {
            rbDebug("Error save string at '\(fileURL)': \(error)")
        }
        
        return false
    }
    
    public static func load(path: String) -> String? {
        let fileURL = URL(fileURLWithPath: path)
        
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            
            rbDebug("Load string from '\(fileURL)'")
            
            return text
        }   
        catch let error {
            rbDebug("Error load string from '\(fileURL)': \(error)")
        }
        
        return nil
    }

}

// -----------------------------------------------------------------------------
// MARK: - Bse64

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
}

