//
//  RBGridArray.swift
//
//  Created by Roger Boesch on 22.03.18.
//  Copyright © 2018 Roger Boesch. All rights reserved.
//
//  Usage:
//   _voxels = RBGridArray<RBSceneObject?>(size: 50, defaultValue: nil)
//   _voxels?.set(x: 49, y: 49, z: 49, RBSceneObject(id: 2112))
//   _voxels?.set(x: 10, y: 23, z: 2, RBSceneObject(id: 2113))
//

import Foundation

struct RBGridArray<T> {
    private var maxSize: Int
    private var gridSize: Int
    private var defaultValue: T
    private var array: [T]
    
    init(size: Int, defaultValue: T) {
        self.gridSize = size
        self.maxSize = self.gridSize * self.gridSize * self.gridSize
        self.defaultValue = defaultValue
        self.array = [T](repeating: defaultValue, count: maxSize)
    }
    
    private subscript(index: Int) -> T {
        assert(index >= 0)
        assert(index < maxSize)
        
        return array[index]
    }
    
    private mutating func set(index: Int, _ newElement: T) {
        assert(index < maxSize)
        array[index] = newElement
    }
    
    mutating func set(x: Int, y: Int, z: Int, _ newElement: T) {
        let index = y * self.gridSize * self.gridSize + (x * self.gridSize + z)
        assert(index < maxSize)
        array[index] = newElement
    }
    
    func get(x: Int, y: Int, z: Int) -> T {
        let index = y * self.gridSize * self.gridSize + (x * self.gridSize + z)
        assert(index < maxSize)
        return array[index]
    }
    
    mutating func clearAll() {
        for i in 0..<maxSize {
            array[i] = defaultValue
        }
    }
    
}
