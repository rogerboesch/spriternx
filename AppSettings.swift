//
//  AppSettings.swift
//
//  Created by Roger Boesch on 30.12.17.
//  Copyright © 2017 Roger Boesch. All rights reserved.
//

import SceneKit

// Application settings
struct Settings {
    static let version: Int = 100
    
    struct Project {
        struct Scene {
            static let MR: Int = 1
            static let Game: Int = 2
        }
    }
    
    struct Command {
        static let addScene: Int = 1
        static let previousBlock: Int = 2
        static let nextBlock: Int = 3
        static let playScene: Int = 4
        static let changeLibrary: Int = 5
        static let help: Int = 6

        static let addCamera: Int = 100
        static let addLight: Int = 101
        
        static let addModel: Int = 208
        static let addTerrain: Int = 209
        static let addFloor: Int = 210
        
        static let toggleConsole: Int = 400
    }
    
    struct UI {
        static let numberOfPatterns = 3

        static let gray: OSColor = NSColor(hex: "#292a2F")
        
        struct CommandView {
            static let background = NSColor(hex: "#292a2F")
        }
        
        struct SpriteView {
            static let background = NSColor(hex: "#292a2F")
        }

        struct PropertyView {
            static let background = NSColor(hex: "#1E2023")
        }
        
        struct Form {
            static let heightOfRuler: CGFloat = 30
            static let heightOfSlider: CGFloat = 30
            static let heightOfSegment: CGFloat = 30
            static let heightOfTitle: CGFloat = 20
            static let heightOfLabel: CGFloat = 16
            static let heightOfColorChooser: CGFloat = 30
            static let heightOfImage: CGFloat = 100
            static let defaultSpace: CGFloat = 5
            
            static let background = NSColor(hex: "#292a2F")
        }
    }
    
}

// Actions for RBObsserver
enum ObserverAction {
    case dataMustBeSaved
    case currentProjectChanged, currentSpriteWillClose, currentSpriteChanged
    case gridChanged, sizeChanged
    case colorChanged, transColorChanged, paletteChanged
    
    case command
}
