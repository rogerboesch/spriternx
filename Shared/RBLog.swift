//
//  RBLog.swift
//  Logging functionality
//
//  Created by Roger Boesch on 02/04/16.
//  Copyright © 2016 Roger Boesch All rights reserved.
//

import Foundation
import SceneKit

enum RBLogSeverity : Int {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case none = 4
}

protocol RBLogger {
    func print(_ message: String, terminate: Bool)
}

public class RBLog: NSObject {
    static var _logger: RBLogger?
    static var _severity = RBLogSeverity.debug

    // -----------------------------------------------------------------------------
    // MARK: - Properties
    
    static var severity: RBLogSeverity {
        get {
            return _severity
        }
        set(value) {
            _severity = value
        }
    }

    // -------------------------------------------------------------------------

    static var logger: RBLogger? {
        get {
            return _logger
        }
        set(value) {
            _logger = value
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Logging severity
        
    fileprivate static func error(message: String) {
        RBLog.log(message: message, severity: "⛔️")
        
        if _logger != nil {
            RBLog.logger(message: message, severity: "⛔️")
        }
    }
    
    // -------------------------------------------------------------------------
    
    fileprivate static func warning(message: String) {
        RBLog.log(message: message, severity: "⚠️")
        
        if _logger != nil {
            RBLog.logger(message: message, severity: "⚠️")
        }
    }

    // -------------------------------------------------------------------------

    fileprivate static func info(message: String) {
        RBLog.log(message: message, severity: "▷")
        
        if _logger != nil {
            RBLog.logger(message: message, severity: "▷")
        }
    }
    
    // -------------------------------------------------------------------------

    fileprivate static func debug(message: String) {
        RBLog.log(message: message, severity: "→")
    }

    // -------------------------------------------------------------------------
    // MARK: - Write logs
    
    private static func log(message: String, severity: String) {
        RBLog.write(message: "\(severity) \(message)")
    }

    // -------------------------------------------------------------------------

    private static func logger(message: String, severity: String) {
        if _logger != nil {
            _logger!.print("\(severity) \(message)", terminate: true)
        }
    }

    // -------------------------------------------------------------------------
    
    fileprivate static func write(message: String, terminate: Bool = true) {
        print(message)
    }

    // -------------------------------------------------------------------------
    
    fileprivate static func printLn(message: String, terminate: Bool = true) {
        print(message)
        
        if _logger != nil {
            _logger!.print(message, terminate: terminate)
        }
    }

    // -------------------------------------------------------------------------

}

// -----------------------------------------------------------------------------
// MARK: - Short functions

func rbError(_ message: String,  _ args: CVarArg...) {
    if (RBLogSeverity.error.rawValue < RBLog.severity.rawValue) {
        return
    }

    let str = String(format: message, arguments: args)
    RBLog.error(message: str)
}

// -----------------------------------------------------------------------------

func rbWarning(_ message: String,  _ args: CVarArg...) {
    if (RBLogSeverity.warning.rawValue < RBLog.severity.rawValue) {
        return
    }

    let str = String(format: message, arguments: args)
    RBLog.warning(message: str)
}

// -----------------------------------------------------------------------------

func rbInfo(_ message: String,  _ args: CVarArg...) {
    if (RBLogSeverity.info.rawValue < RBLog.severity.rawValue) {
        return
    }

    let str = String(format: message, arguments: args)
    RBLog.info(message: str)
}

// -----------------------------------------------------------------------------

func rbDebug(_ message: String,  _ args: CVarArg...) {
    if (RBLogSeverity.debug.rawValue < RBLog.severity.rawValue) {
        return
    }

    let str = String(format: message, arguments: args)
    RBLog.debug(message: str)
}

// -----------------------------------------------------------------------------

func rbPrint(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.printLn(message: str, terminate: false)
}

// -----------------------------------------------------------------------------

func rbPrintLine(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.printLn(message: str)
}

// -----------------------------------------------------------------------------
