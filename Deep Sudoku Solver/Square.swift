//
//  Square.swift
//  Sudoku Solver
//
//  Created by Bernd Beuster on 23.10.14.
//  Copyright (c) 2014 Bernd Beuster. All rights reserved.
//

import Foundation

struct Square: CustomStringConvertible {
    var value = UInt16(0)
    
    init(_ value: UInt16 = 0) {
        self.value = value
    }
    
    /* Return description for protocol Printable. */
    var description: String {
        if value == 0 {
            return "-"
        } else {
            var str = String()
            for i in 1...9 {
                if (value & (toMask(i)) != 0) {
                    str += String(i)
                }
            }
            return str
        }
    }
    
    /* Return the number of set digits in value. */
    var count: Int {
        var val = value
        var count = 0
        
        while val != 0 {
            val &= val - 1 // clear the least significant bit set
            count += 1
        }
        return count
    }
    
    func toMask(_ digit: Int) -> UInt16 {
        assert(digit >= 1 && digit <= 9, "Index out of range.")
        return UInt16(1 << (digit - 1))
    }
    
    func hasDigit(_ digit: Int) -> Bool {
        return (value & toMask(digit)) != 0
    }
    
    mutating func addDigit(_ digit: Int) {
        value |= toMask(digit)
    }
    
    mutating func removeDigit(_ digit: Int) {
        value &= ~toMask(digit)
    }
    
    var digits: [Int] {
        var res = [Int]()
        for i in 1...9 {
            if hasDigit(i) {
                res.append(i)
            }
        }
        return res
    }
}
