//
//  Node.swift
//  A Star
//
//  Created by Jan Müller on 02.03.19.
//  Copyright © 2019 Jan Müller. All rights reserved.
//

import Foundation

@objc public enum NodeState: UInt {
    case unchecked = 0, open = 1, closed = 2, path = 3
}

@objcMembers public class Node: NSObject {
    
    public let x: Int
    public let y: Int
    
    public var parent: Node?
    public var type: FieldType
    
    public var gCost: Double
    public var hCost: Double
    public var totalCost: Double
    
    dynamic public var state: NodeState = .unchecked
    
    // parent == nil is root node
    init(x: Int, y: Int, type: FieldType = .unknown, parent: Node? = nil) {
        self.x = x
        self.y = y
        self.parent = parent
        self.type = type
        self.gCost = 0
        self.hCost = 0
        self.totalCost = 0
        
        super.init()
    }
    
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.type == rhs.type
    }
    
    public override var description: String {
        return self.debugDescription
    }
    
    public override var debugDescription: String {
        return "Node: type:\(self.type) x: \(self.x) y:\(self.y) gCost:\(self.gCost) hCost:\(self.hCost) totalCost:\(self.totalCost) parent.x: \(String(describing: self.parent?.x)) parent.y:\(String(describing: self.parent?.y))"
    }
}

// costs calculation

extension Node {
    
    public func calculateCosts(withParent parent: Node?, goal: Node, heuristic: Heuristic) {
        // calc gCost
        if let parent = parent {
            self.gCost = parent.gCost + self.pathCostsToNeighbor(parent)
        } else {
            self.gCost = 0
        }
        
        // calc hCost
        switch heuristic {
        case .manhattan:
            self.hCost = Double(abs(goal.x - self.x) + abs(goal.y - self.y)) * Constants.StepCosts.straight
        case .chebyshev:
            self.hCost = Double(max(abs(goal.x - self.x), abs(goal.y - self.y))) * Constants.StepCosts.straight
        case .euclidean:
            self.hCost = Double(sqrt(pow(Double(goal.x - self.x), 2) + pow(Double(goal.y - self.y), 2))) * Constants.StepCosts.straight
        }
        
        // sum it up
        self.totalCost = self.gCost + self.hCost
    }
    
    private func pathCostsToNeighbor(_ neighbor: Node) -> Double {
        // only handle neighbors
        guard abs(neighbor.x - self.x) <= 1,
            abs(neighbor.y - self.y) <= 1 else {
                return Double.infinity
        }
        let isDiagonal = self.x != neighbor.x && self.y != neighbor.y
        return isDiagonal ? Constants.StepCosts.diagonal : Constants.StepCosts.straight
    }
    
}
