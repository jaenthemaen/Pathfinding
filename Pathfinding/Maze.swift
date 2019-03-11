//
//  Maze.swift
//  A Star
//
//  Created by Jan Müller on 02.03.19.
//  Copyright © 2019 Jan Müller. All rights reserved.
//

import Foundation

public enum FieldType: CaseIterable {
    case start, free, wall, goal, unknown
    
    mutating func next() {
        let allCases = type(of: self).allCases
        self = allCases[(allCases.index(of: self)! + 1) % allCases.count]
    }
    
    mutating func previous() {
        let allCases = type(of: self).allCases
        let currIndex = allCases.index(of: self)!
        self = allCases[currIndex > 0 ? currIndex-1 : allCases.count-1]
    }
}



public class Maze {
    
    private let initialLines: [String]?
    private var nodes: [[Node]]
    private let startGlyph: String
    private let goalGlyph: String
    private let wallGlyph: String
    private let freeGlyph: String
    private let unknownGlyph: String
    
    init(width: Int, height: Int, startGlyph: String = "S", goalGlyph: String = "G", wallGlyph: String = "#", freeGlyph: String = "O", unknownGlyph: String = "?") {
        self.nodes = (0..<height).map({ row -> [Node] in
            (0..<width).map({ column -> Node in
                return Node(x: column, y: row, type: .free, parent: nil)
            })
        })
        
        self.startGlyph = startGlyph
        self.goalGlyph = goalGlyph
        self.wallGlyph = wallGlyph
        self.freeGlyph = freeGlyph
        self.unknownGlyph = unknownGlyph
        
        self.initialLines = nil
    }
    
    init(lines: [String], startGlyph: String = "S", goalGlyph: String = "G", wallGlyph: String = "#", freeGlyph: String = "O", unknownGlyph: String = "?") {
        self.initialLines = lines
        
        self.startGlyph = startGlyph
        self.goalGlyph = goalGlyph
        self.wallGlyph = wallGlyph
        self.freeGlyph = freeGlyph
        self.unknownGlyph = unknownGlyph
        
        self.nodes = Maze.convertMazeStrings(lines, startGlyph: startGlyph, goalGlyph: goalGlyph, wallGlyph: wallGlyph, freeGlyph: freeGlyph, unknownGlyph: unknownGlyph)
    }
    
    static private func convertMazeStrings(_ strings: [String], startGlyph: String, goalGlyph: String, wallGlyph: String, freeGlyph: String, unknownGlyph: String) -> [[Node]] {
        
        var nodes: [[Node]] = []
        for (row, str) in strings.enumerated() {
            var rowNodes: [Node] = []
            for (column, ch) in str.enumerated() {
                let type: FieldType = { switch String(ch) {
                    case startGlyph:
                        return .start
                    case goalGlyph:
                        return .goal
                    case wallGlyph:
                        return .wall
                    case freeGlyph:
                        return .free
                    case unknownGlyph:
                        return .unknown
                    default:
                        return .unknown
                    }
                }()
                rowNodes.append(Node(x: column, y: row, type: type, parent: nil))
            }
            nodes.append(rowNodes)
        }
        
        return nodes
    }
    
    public func generateStringRepresentation() -> [String] {
        return self.nodes.map { r -> String in
            return r.map({ node -> String in
                switch node.type {
                case .start:
                    return self.startGlyph
                case .goal:
                    return self.goalGlyph
                case .wall:
                    return self.wallGlyph
                case .free:
                    return self.freeGlyph
                case .unknown:
                    return self.unknownGlyph
                }
            }).joined()
        }
    }
    
    public func changeTypeAt(x: Int, y: Int, toType type: FieldType) {
        guard x < self.nodes.first?.count ?? 0, y < self.nodes.count else {
            return
        }
        
        self.nodes[y][x].type = type
    }
    
    private var allNodes: [Node] {
        return self.nodes.flatMap({ $0 })
    }
    
    public var startNode: Node? {
        return self.firstNode(ofType: .start)
    }
    
    public var goalNode: Node? {
        return self.firstNode(ofType: .goal)
    }
    
    private func firstNode(ofType type: FieldType) -> Node? {
        return self.allNodes.first(where: { (node) -> Bool in
            return node.type == type
        })
    }
    
    public func nodeAt(x: Int, y: Int) -> Node? {
        guard y >= 0 && y < self.nodes.count,
            x >= 0 && x < self.nodes[0].count else {
                return nil
        }
        
        return self.nodes[y][x]
    }
    
    public func freeNeighborNodesOf(_ node: Node, allowedMovements: AllowedMovements) -> [Node] {
        var nodes: [Node] = []
        
        // TODO respect movement here
        
        let isFirstRow = node.y == 0
        let isLastRow = node.y == self.nodes.count - 1
        let isFirstColumn = node.x == 0
        let isLastColumn = node.x == self.nodes[0].count - 1
        
        if !isFirstRow {
            nodes.append(self.nodes[node.y - 1][node.x])
            
            if allowedMovements == .straightAndDiagonal {
                if !isFirstColumn {
                    nodes.append(self.nodes[node.y - 1][node.x - 1])
                }
                
                if !isLastColumn {
                    nodes.append(self.nodes[node.y - 1][node.x + 1])
                }
            }
            
        }
        
        if !isFirstColumn {
            nodes.append(self.nodes[node.y][node.x - 1])
        }
        
        if !isLastColumn {
            nodes.append(self.nodes[node.y][node.x + 1])
        }
        
        if !isLastRow {
            nodes.append(self.nodes[node.y + 1][node.x])
            
            if allowedMovements == .straightAndDiagonal {
                if !isFirstColumn {
                    nodes.append(self.nodes[node.y + 1][node.x - 1])
                }
                
                if !isLastColumn {
                    nodes.append(self.nodes[node.y + 1][node.x + 1])
                }
            }
        }
        
        return nodes.filter({ node -> Bool in
            let validTypes: [FieldType] = [.free, .goal]
            return validTypes.contains(node.type)
        })
    }
    
    public func resetNodeStates() {
        for node in self.allNodes where node.state != .unchecked {
            node.state = .unchecked
        }
    }
}
