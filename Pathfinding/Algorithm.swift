//
//  Algorithm.swift
//  A_Star_Interactive
//
//  Created by Jan Müller on 04.03.19.
//  Copyright © 2019 Jan Müller. All rights reserved.
//

import Foundation

protocol Algorithm {
    // initializing
    init?(maze: Maze, heuristic: Heuristic, movement: AllowedMovements)
    
    // controlling
    func run()
    func step()
    func stop()
    
}
