//
//  Grid.swift
//  Sudoku Solver
//
//  Created by Bernd Beuster on 23.10.14.
//  Copyright (c) 2014 Bernd Beuster. All rights reserved.
//

import Foundation

/* Global constants */
let rows = 9, columns = 9
var units = [[[Int]]]()
var peers = [[Int]]()

class Grid: CustomStringConvertible {
    /* To start, every square can be any digit */
    var values = [Square](repeating: Square(0x1ff), count: rows * columns)
    
    /* Return description for protocol Printable. */
    var description: String {
        /* Convert to NSString in order to determine the string length. */
        let values = self.values.map { NSString(string: "\($0)") }
        
        /* max. string length of every value */
        var maxLen = 0
        for v in values {
            maxLen = max(maxLen, v.length)
        }
        
        /* Build line */
        var lineSegment = String()
        for _ in 0..<3*maxLen + 2 {
            lineSegment += "-"
        }
        let line = [lineSegment,lineSegment,lineSegment].joined(separator: "+")
        
        /* Build table grid */
        var row = [String]()
        for r in 0..<rows {
            var col = [String]()
            
            for i in 0..<columns {
                col.append(values[r * columns + i].padding(toLength: maxLen, withPad: " ", startingAt: 0))
            }
            
            let c0 = col[0...2].joined(separator: " ")
            let c1 = col[3...5].joined(separator: " ")
            let c2 = col[6...8].joined(separator: " ")
            row.append([c0,c1,c2].joined(separator: "|"))
        }
        
        let r0 = row[0...2].joined(separator: "\n")
        let r1 = row[3...5].joined(separator: "\n")
        let r2 = row[6...8].joined(separator: "\n")
        return [r0,r1,r2].joined(separator: "\n\(line)\n") + "\n"
    }
    
    /* Convert grid into an array of Int with '0' or '.' for empties. */
    func gridValues(_ grid: String) -> [Int] {
        var res = [Int]()
        for c in grid {
            switch c {
            case "0",".":
                res.append(0)
            default:
                if let d = Int(String(c)) {
                    res.append(d)
                }
            }
        }
        return res
    }
    
    init(_ grid: String) {
        /* Assign values from the grid. */
        let intValues = gridValues(grid)
        for i in 0..<(rows * columns) {
            if intValues[i] > 0 {
                if assign(i, d: intValues[i]) == nil {
                    values = [] // Fail if we can't assign value to square i.
                }
            }
        }
    }
    
    /* Eliminate all the other values (except d) from values[s] and propagate.
    Return values, except return nil if a contradiction is detected. */
    func assign(_ s: Int, d: Int) -> [Square]? {
        var otherValues = values[s]
        otherValues.removeDigit(d)
        
        for d2 in otherValues.digits {
            if eliminate(s, d: d2) == nil { return nil }
        }
        return values
    }
    
    /* Eliminate d from values[s]; propagate when values or places <= 2.
    Return values, except return nil if a contradiction is detected. */
    func eliminate(_ s: Int, d: Int) -> [Square]? {
        if !values[s].hasDigit(d) { return values } // Already eliminated
        
        values[s].removeDigit(d)
        
        /* (1) If a square s is reduced to one value d2, then eliminate d2 from the peers. */
        let count = values[s].count
        if count == 0 { return nil } // Contradiction: removed last value
        else if count == 1 {
            let d2 = values[s].digits[0]
            for s2 in peers[s] {
                if eliminate(s2, d: d2) == nil { return nil }
            }
        }
        
        /* (2) If a unit u is reduced to only one place for a value d, then put it there. */
        for u in units[s] {
            var dPlaces = 0, dPlacesCount = 0
            for s in u {
                if values[s].hasDigit(d) {
                    dPlaces = s
                    dPlacesCount += 1
                }
            }
            if dPlacesCount == 0 { return nil } // Contradiction: no place for this value
            else if dPlacesCount == 1 {
                
                /* d can only be in one place in unit; assign it there */
                if assign(dPlaces, d: d) == nil { return nil }
            }
        }
        return values
    }
    
    /* Check if puzzle is solved. */
    var solved: Bool {
        for s in values {
            if s.count != 1 { return false }
        }
        return true
    }
    
    /* Using depth-first search and propagation, try all possible values. */
    func search() -> [Square]? {
        if solved { return values } // Solved!
        
        /* Chose the unfilled square s with the fewest possibilities. */
        var minCount = Int.max, s = 0
        for i in 0..<(rows * columns) {
            let count = values[i].count
            if count > 1 && count < minCount {
                minCount = count
                s = i
            }
        }
        
        /* Try all possible values. */
        for d in values[s].digits {
            let values = self.values // save state
            if assign(s, d: d) != nil {
                _ = search()
            }
            if !solved { self.values = values } // restore state
        }
        return nil
    }
}
