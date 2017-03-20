//
//  utilities.swift
//  Sudoku Solver
//
//  Created by Bernd Beuster on 24.10.14.
//  Copyright (c) 2014 Bernd Beuster. All rights reserved.
//

import Foundation

/* A unit are the columns 1-9, the rows A-I and
a collection of nine squares. */
func squareUnits(_ s: Int) -> [[Int]] {
    
    /* same row */
    var row = s / columns
    var rowUnits = [Int](repeating: 0, count: columns)
    var i = 0
    for column in 0..<columns {
        rowUnits[i] = row * columns + column
        i += 1
    }
    
    /* same column */
    var column = s % rows
    var columnUnits = [Int](repeating: 0, count: rows)
    i = 0
    for row in 0..<rows {
        columnUnits[i] = row * columns + column
        i += 1
    }
    
    /* 3x3 box */
    row = 3 * (s / (3 * columns))
    column = 3 * ((s % rows) / 3)
    var boxUnits = [Int](repeating: 0, count: 3 * 3)
    for r in 0..<3 {
        for c in 0..<3 {
            let i = r * 3 + c
            boxUnits[i] = (row + r) * columns + (column + c)
        }
    }
    return [rowUnits, columnUnits, boxUnits]
}

/* The peers are the squares that share a unit. */
func squarePeers(_ s: Int) -> NSMutableSet {
    let peers = NSMutableSet(capacity: 20)
    
    /* same row */
    var row = s / columns
    for column in 0..<columns {
        let i = row * columns + column
        if i != s { peers.add(i) }
    }
    
    /* same column */
    var column = s % rows
    for row in 0..<rows {
        let i = row * columns + column
        if i != s { peers.add(i) }
    }
    
    /* 3x3 box */
    row = 3 * (s / (3 * columns))
    column = 3 * ((s % rows) / 3)
    for r in 0..<3 {
        for c in 0..<3 {
            let i = (row + r) * columns + (column + c)
            if i != s { peers.add(i) }
        }
    }
    return peers
}

/* Parse a file into a list of strings, separated by separator. */
func fromFile(_ fileName: String, separator: String = "\n") -> [String] {
    let res = [String]()
    if let data = try? Data(contentsOf: URL(fileURLWithPath: fileName)) {
        if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            let res = str.components(separatedBy: separator) 
            return res.filter { !$0.isEmpty }
        }
    }
    return res
}

/* Solve one grid */
func solve(_ grid: String) -> Grid {
    let g = Grid(grid)
    _ = g.search()
    return g
}

/* Attempt to solve a sequence of grids. Report results.
When showif is false, don't display any puzzles.
*/
func solveAll(_ grids: [String], name: String = "", showIf: Bool = false) {
    var maxTime = UInt64(0), sumTime = UInt64(0)
    var n = 0, solved = 0
    for grid in grids {
        let startTime = mach_absolute_time()
        let g = solve(grid)
        let elapsedTime = mach_absolute_time() - startTime

        maxTime = max(maxTime, elapsedTime)
        sumTime += elapsedTime
        n += 1
        if g.solved { solved += 1 }
        
        if showIf {
            print(grid)
            print(g)
        }
    }
    
    let realMaxTime = Double(maxTime) * 1.0e-9
    let realTime = Double(sumTime) * 1.0e-9 / Double(n)
    print("Solved \(solved) of \(n) \(name) puzzles (avg \(realTime) secs (\(1.0/realTime) Hz), max \(realMaxTime) secs).")
}
