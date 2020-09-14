//
//  RB+FileManager.swift
//  Filemanager extension
//
//  Created by Roger Boesch on 01/05/16.
//  Copyright © 2016 Roger Boesch All rights reserved.
//

import Foundation

// -----------------------------------------------------------------------------
// MARK: - Directory helpers

extension FileManager {
    
    static func documents() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first!
    }
    
    class func folderInDocuments(_ name: String) -> URL {
        return FileManager.documents().appendingPathComponent(name)
    }
    
    class func fileInDocuments(_ name: String) -> URL {
        return FileManager.documents().appendingPathComponent(name)
    }
    
    class func createFolderInDocuments(_ name: String) -> Bool {
        let outputPath = folderInDocuments(name).path
        
        if FileManager.default.fileExists(atPath: outputPath) {
            return true
        }
        
        do {
            try FileManager.default.createDirectory(atPath: outputPath, withIntermediateDirectories: false, attributes: nil)
        }
        catch let error as NSError {
            rbWarning("Create directory failed: '\(outputPath)': \(error.localizedDescription)")
            return false;
        }
        
        rbDebug("Create directory at: '\(outputPath)'")
        
        return true
    }
    
    class func filesInDocuments() -> [String] {
        let myFolder = FileManager.documents().path

        do {
            let fileList = try FileManager.default.contentsOfDirectory(atPath: myFolder)
            return fileList
        }
        catch let error as NSError {
            rbWarning("List file in folder failed: '\(myFolder)' reason: '\(error.localizedDescription)'")
            return []
        }
    }
    
    class func filesInDocuments(folder: String) -> [String] {
        let myFolder = FileManager.documents().path + "/" + folder

        do {
            let fileList = try FileManager.default.contentsOfDirectory(atPath: myFolder)
            
            return fileList
        }
        catch let error as NSError {
            rbWarning("List file in folder failed: '\(myFolder)' -> \(error.localizedDescription)")
            return []
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - File helpers

extension FileManager {
    
    class func delete(filename: String) -> Bool {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: filename)
        }
        catch let error as NSError {
            rbWarning("Can't delete file '%@': %@", filename, error.localizedDescription)
            return false
        }
        
        return true
    }
    
    class func copy(from: String, to: String, overwrite: Bool = false) -> Bool {
        let fileManager = FileManager.default
        
        if overwrite {
            // Delete first destination
            _ = FileManager.delete(filename: to)
        }
        
        do {
            try fileManager.copyItem(atPath: from, toPath: to)
        }
        catch let error as NSError {
            rbWarning("Can't copy file '%@' from '%@': '%@'", from, to, error.localizedDescription)
            return false
        }
        
        return true
    }
    
    class func exists(path: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path)
    }
}
