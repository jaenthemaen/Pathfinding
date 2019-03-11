//
//  A_StarTests.swift
//  A StarTests
//
//  Created by Jan Müller on 02.03.19.
//  Copyright © 2019 Jan Müller. All rights reserved.
//

import XCTest
@testable import A_Star_Interactive

class A_StarTests: XCTestCase {

    override func setUp() {
        
    }

    override func tearDown() {
        
    }

    func testWithInts() {
        let ints = [5, 10, 20, 1, 17, 4, 35]
        let sorting: (Int, Int) -> Bool = (<)
        
        var heap = Heap(nodes: ints, sorting: sorting)
        
        XCTAssertEqual(2, heap.depth)
        XCTAssertEqual(7, heap.size)
        
        XCTAssertEqual(1, heap.remove() ?? 0)
        XCTAssertEqual(6, heap.size)
        
        XCTAssertEqual(4, heap.remove() ?? 0)
    }
    
    func testWithStrings() {
        let strings = ["dddd", "A", "Z", "___!A", "GG", "EZ", "FFS"]
        let sorting: (String, String) -> Bool = { s1, s2 in s1.caseInsensitiveCompare(s2) == .orderedAscending }
        
        var heap = Heap(nodes: strings, sorting: sorting)
        
        XCTAssertEqual(2, heap.depth)
        XCTAssertEqual(7, heap.size)
        
        XCTAssertEqual("___!A", heap.remove() ?? "bar")
        XCTAssertEqual(6, heap.size)
        
        XCTAssertEqual("A", heap.remove() ?? "baz")
        XCTAssertEqual("dddd", heap.remove() ?? "baz")
        XCTAssertEqual("EZ", heap.remove() ?? "baz")
        XCTAssertEqual("FFS", heap.remove() ?? "baz")
    }
    
    func testEmptyMaze() {
        let maze = Maze(width: 5, height: 5)
        
        let expectedOutput = ["OOOOO", "OOOOO", "OOOOO", "OOOOO", "OOOOO"]
        
        let output = maze.generateStringRepresentation()
        
        XCTAssertEqual(expectedOutput, output)
    }
    
    func testEmptyMazeWithDifferentChar() {
        let maze = Maze(width: 5, height: 5, freeGlyph: "⬜️")
        
        let expectedOutput = ["⬜️⬜️⬜️⬜️⬜️", "⬜️⬜️⬜️⬜️⬜️", "⬜️⬜️⬜️⬜️⬜️", "⬜️⬜️⬜️⬜️⬜️", "⬜️⬜️⬜️⬜️⬜️"]
        
        let output = maze.generateStringRepresentation()
        
        XCTAssertEqual(expectedOutput, output)
    }
    
    func testSettingStartAndEnd() {
        var maze = Maze(width: 5, height: 5, startGlyph:"🚩", goalGlyph: "🏁", freeGlyph: "⬜️")
        maze.changeFieldAt(x: 2, y: 1, toType: .start)
        maze.changeFieldAt(x: 4, y: 4, toType: .goal)
        
        let expectedOutput = ["⬜️⬜️⬜️⬜️⬜️", "⬜️⬜️🚩⬜️⬜️", "⬜️⬜️⬜️⬜️⬜️", "⬜️⬜️⬜️⬜️⬜️", "⬜️⬜️⬜️⬜️🏁"]
        
        let output = maze.generateStringRepresentation()
        
        XCTAssertEqual(expectedOutput, output)
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
