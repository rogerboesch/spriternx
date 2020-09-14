//
//  RB+FileHandle.swift
//  FileHandle extensions
//
//  Created by appsAndYOU Ltd. on 01/01/16.
//  Copyright © 2016 appsAndYOU Ltd. All rights reserved.
//

import SceneKit

// -----------------------------------------------------------------------------
// MARK: - Read functions

extension FileHandle {
    
    func readString(length: Int) -> String {
        let data = self.readData(ofLength: length)
        let str = String(data: data, encoding: .utf8)
        
        if str == nil {
            return ""
        }
        
        return str!
    }
    
    func readInt(length: Int = 6) -> Int {
        let data = self.readData(ofLength: length)
        let str = String(data: data, encoding: .utf8)
        if str == nil {
            return 0
        }
        
        let value = Int(str!.trim())
        if value == nil {
            return 0
        }
        
        return value!
    }
    
    func readBool() -> Bool {
        let data = self.readData(ofLength: 1)
        let str = String(data: data, encoding: .utf8)
        if str == nil {
            return false
        }
        
        if str!.trim() == "T" {
            return true
        }
        
        return false
    }

    func readVector() -> OSVector3? {
        let data = self.readData(ofLength: 9)
        
        var str = String(data: data, encoding: .utf8)
        if str == nil {
            return nil
        }

        let xStr = str!.substring(toIndex: 3)
        let x = Int(xStr)
        str = str!.substring(fromIndex: 3)

        let yStr = str!.substring(toIndex: 3)
        let y = Int(yStr)
        str = str!.substring(fromIndex: 3)

        let z = Int(str!)

        if x == nil || y == nil || z == nil {
            return nil
        }
        
        return OSVector3(x!, y!, z!)
    }

}

// -----------------------------------------------------------------------------
// MARK: - Write functions

extension FileHandle {
    
    func writeString(_ value: String, length: Int) -> Bool {
        let str = FileHandle.fillString(value, length: length)
        let data = str.data(using: .utf8)
        if data == nil {
            return false
        }
        
        self.write(data!)
        return true
    }
    
    func writeInt(_ value: Int, _ length: Int = 6) -> Bool {
        return writeString(String(value), length: length)
    }
    
    func writeLarge(_ value: Double) -> Bool {
        return writeString(String(format: "%09d", value), length: 9)
    }

    func writeVector(_ value: OSVector3) -> Bool {
        return writeString(String(format: "%03d%03d%03d", Int(value.x), Int(value.y), Int(value.z)), length: 9)
    }

    func writeBool(_ value: Bool) -> Bool {
        if value {
            return writeString("T", length: 1)
        }
        else {
            return writeString("F", length: 1)
        }
    }
    
    class func fillString(_ str: String, length: Int) -> String {
        if str.count < length {
            var filled = str
            while filled.count < length {
                filled = filled + " "
            }
            
            return filled
        }
        else if str.count > length {
            return str.substring(toIndex: length)
        }
        
        // OK
        return str
    }
    
}

// -----------------------------------------------------------------------------

