//
//  Constants.swift
//  A_Star_Interactive
//
//  Created by Jan Müller on 04.03.19.
//  Copyright © 2019 Jan Müller. All rights reserved.
//

import Foundation

/// MARK: Enums

public enum Heuristic {
    case manhattan
    case chebyshev
    case euclidean
}

public enum AllowedMovements {
    case straight
    case straightAndDiagonal
}

public enum AlgorithmState {
    case ready
    case running
    case finished
}

/// MARK: Constants

struct Constants {
    
    struct StepCosts {
        static let straight: Double = 10.0
        static let diagonal: Double = 14.0
    }
    
}
