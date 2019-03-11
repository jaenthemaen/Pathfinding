//
//  Heap.swift
//  A Star
//
//  Created by Jan Müller on 02.03.19.
//  Copyright © 2019 Jan Müller. All rights reserved.
//

import Foundation

public struct Heap<T> {
    
    private var sorting: (T, T) -> Bool
    private var nodes: [T]
    
    public init(nodes: [T], sorting: @escaping (T, T) -> Bool) {
        self.sorting = sorting
        self.nodes = nodes
        
        self.buildHeap()
    }
    
    /// Heap Info
    
    public var size: Int {
        return self.nodes.count
    }
    
    public var isEmpty: Bool {
        return self.nodes.isEmpty
    }
    
    public var depth: Int {
        return Int(floor(log2(Double(self.size))))
    }
    
    /// Build Up
    
    private mutating func buildHeap() {
        // fastet way to build a heap: traverse upper half of population and sort down!
        for i in stride(from: (self.nodes.count / 2 - 1), through: 0, by: -1) {
            self.shiftDown(i)
        }
    }
    
    /// Index Calculations
    
    @inline(__always) internal func parentIndex(ofIndex i: Int) -> Int {
        return (i - 1) / 2
    }
    
    @inline(__always) internal func leftChildIndex(ofIndex i: Int) -> Int {
        return 2 * i + 1
    }
    
    @inline(__always) internal func rightChildIndex(ofIndex i: Int) -> Int {
        return 2 * i + 2
    }
    
    /// Insertion & Deletion
    
    public mutating func remove() -> T? {
        guard !self.nodes.isEmpty else {
            return nil
        }
        
        if self.nodes.count == 1 {
            return self.nodes.removeLast()
        } else {
            let first = self.nodes.first
            self.nodes[0] = self.nodes.removeLast()
            self.shiftDown(0)
            return first
        }
    }
    
    @discardableResult public mutating func remove(at index: Int) -> T? {
        guard index < nodes.count else {
            return nil
        }
        
        let lastIndex = nodes.count - 1
        
        if index != lastIndex {
            nodes.swapAt(index, lastIndex)
            shiftDown(from: index, until: lastIndex)
            shiftUp(index)
        }
        
        return nodes.removeLast()
    }
    
    public mutating func insert(_ value: T) {
        nodes.append(value)
        shiftUp(nodes.count - 1)
    }
    
    public mutating func replace(index i: Int, value: T) {
        guard i < nodes.count else {
            return
        }
        
        remove(at: i)
        insert(value)
    }
    
    /// Sorting, e.g. shifting up & down
    
    internal mutating func shiftUp(_ index: Int) {
        var currentNodeIndex = index
        let node = nodes[currentNodeIndex]
        var parentIndex = self.parentIndex(ofIndex: currentNodeIndex)
        
        // while not at root and sorting is false (node should be before parent): swap!
        while currentNodeIndex > 0 && self.sorting(node, nodes[parentIndex]) {
            nodes[currentNodeIndex] = nodes[parentIndex]
            currentNodeIndex = parentIndex
            parentIndex = self.parentIndex(ofIndex: currentNodeIndex)
        }
        
        nodes[currentNodeIndex] = node
    }
    
    internal mutating func shiftDown(from index: Int, until endIndex: Int) {
        let leftChildIndex: Int = self.leftChildIndex(ofIndex: index)
        let rightChildIndex: Int = leftChildIndex + 1
        
        var swapTargetIndex: Int = index
        
        if leftChildIndex < endIndex && self.sorting(nodes[leftChildIndex], nodes[swapTargetIndex]) {
            swapTargetIndex = leftChildIndex
        }
        if rightChildIndex < endIndex && self.sorting(nodes[rightChildIndex], nodes[swapTargetIndex]) {
            swapTargetIndex = rightChildIndex
        }
        
        // sorted correctly already? abort shift.
        if swapTargetIndex == index {
            return
        }
        
        nodes.swapAt(index, swapTargetIndex)
        shiftDown(from: swapTargetIndex, until: endIndex)
    }
    
    internal mutating func shiftDown(_ index: Int) {
        shiftDown(from: index, until: nodes.count)
    }
}

/// MARK: Equatable extension

extension Heap where T: Equatable {
    
    public func contains(_ node: T) -> Bool {
        return self.index(of: node) != nil
    }
    
    public func index(of node: T) -> Int? {
        return nodes.index(where: {
            $0 == node
        })
    }
    
    @discardableResult public mutating func remove(node: T) -> T? {
        if let index = index(of: node) {
            return remove(at: index)
        }
        return nil
    }

}
