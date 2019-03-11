//
//  AStarAlgorithm.swift
//  A_Star_Interactive
//
//  Created by Jan Müller on 03.03.19.
//  Copyright © 2019 Jan Müller. All rights reserved.
//

import Foundation

class AStarAlgorithm: Algorithm {
    
    private let heuristic: Heuristic
    private let movement: AllowedMovements
    
    private var maze: Maze
    private let startNode: Node
    private let goalNode: Node
    
    private var turns: Int = 0
    
    private(set) var state: AlgorithmState = .ready
    private var timer: Timer?
    
    private var openHeap: Heap<Node> = Heap(nodes: [], sorting: { (node1, node2) -> Bool in
        return node1.totalCost < node2.totalCost
    })
    private var closedHeap: Heap<Node> = Heap(nodes: [], sorting: { (node1, node2) -> Bool in
        return node1.totalCost < node2.totalCost
    })
    
    required init?(maze: Maze, heuristic: Heuristic = .manhattan, movement: AllowedMovements = .straightAndDiagonal) {
        guard let startPos = maze.startNode,
            let goalPos = maze.goalNode else {
                return nil
        }
        
        self.maze = maze
        
        self.startNode = startPos
        self.goalNode = goalPos
        
        self.heuristic = heuristic
        self.movement = movement
        
        self.startNode.state = .open
        self.startNode.calculateCosts(withParent: nil, goal: self.goalNode, heuristic: .manhattan)
        self.openHeap.insert(self.startNode)
    }
    
    // Public control functions
    
    public func step() {
        guard let node = self.openHeap.remove() else {
            self.state = .finished
            return
        }
        
        if self.state != .running {
            self.state = .running
        }
        
        // Are we done yet?
        if node == self.goalNode {
            self.setPathFromNode(node)
            self.state = .finished
            return
        }
        
        node.state = .closed
        self.closedHeap.insert(node)
        
        let neighbors = self.maze.freeNeighborNodesOf(node, allowedMovements: self.movement).filter { nb -> Bool in
            return !self.closedHeap.contains(nb)
        }
        
        for neighbor in neighbors {
            if self.openHeap.contains(neighbor) {
                // compare g costs
                if let neighborParent = neighbor.parent, neighborParent.gCost > node.gCost {
                    neighbor.parent = node
                    neighbor.calculateCosts(withParent: node, goal: self.goalNode, heuristic: self.heuristic)
                }
                
            } else {
                neighbor.parent = node
                neighbor.state = .open
                neighbor.calculateCosts(withParent: node, goal: self.goalNode, heuristic: self.heuristic)
                self.openHeap.insert(neighbor)
            }
        }
    }
    
    public func run() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] t in
            if self?.state == .finished {
                t.invalidate()
            } else {
                self?.step()
            }
        }
        self.timer?.fire()
    }
    
    public func stop() {
        self.timer?.invalidate()
        self.state = .finished
    }
    
    // Set path state on all nodes of the shortest path so the UI can update accordingly
    
    private func setPathFromNode(_ node: Node) {
        var currentNode: Node? = node
        while currentNode != nil {
            currentNode?.state = .path
            currentNode = currentNode?.parent
        }
    }
    
}
