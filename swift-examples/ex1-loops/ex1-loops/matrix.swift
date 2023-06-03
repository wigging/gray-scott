//
//  matrix.swift
//  ex1-loops
//
//  Created by Gavin Wiggins on 6/3/23.
//

import Accelerate

public struct Matrix {
    
    let rows: Int
    let columns: Int
    var grid: [Float]
        
    public init(rows: Int, columns: Int, fill: Float = 0) {
        self.rows = rows
        self.columns = columns
        self.grid = Array(repeating: fill, count: rows * columns)
    }
        
    public init(rows: Int, columns: Int, values: [Float]) {
        self.rows = rows
        self.columns = columns
        self.grid = values
    }
    
    public init(_ array2d: [[Float]]) {
        self.rows = array2d.count
        self.columns = array2d[0].count
        self.grid = array2d.flatMap { $0 }
    }
    
    public subscript(row: Int, column: Int) -> Float {
        get { return grid[(row * columns) + column] }
        set { grid[(row * columns) + column] = newValue }
    }
    
    static public func * (lhs: Matrix, rhs: Matrix) -> Matrix {
        let v = vDSP.multiply(lhs.grid, rhs.grid)
        let m = Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
        return m
    }
    
    static public func * (lhs: Float, rhs: Matrix) -> Matrix {
        let v = vDSP.multiply(lhs, rhs.grid)
        let m = Matrix(rows: rhs.rows, columns: rhs.columns, values: v)
        return m
    }
    
    static public func * (lhs: Matrix, rhs: Float) -> Matrix {
        let v = vDSP.multiply(rhs, lhs.grid)
        let m = Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
        return m
    }
    
    static public func / (lhs: Matrix, rhs: Float) -> Matrix {
        let v = vDSP.divide(lhs.grid, rhs)
        let m = Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
        return m
    }
    
    static public func + (lhs: Matrix, rhs: Matrix) -> Matrix {
        let v = vDSP.add(lhs.grid, rhs.grid)
        return Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
    }

    static public func + (lhs: Float, rhs: Matrix) -> Matrix {
        let v = vDSP.add(lhs, rhs.grid)
        return Matrix(rows: rhs.rows, columns: rhs.columns, values: v)
    }
    
    static public func + (lhs: Matrix, rhs: Float) -> Matrix {
        let v = vDSP.add(rhs, lhs.grid)
        return Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
    }
    
    static public func - (lhs: Matrix, rhs: Matrix) -> Matrix {
        let v = vDSP.subtract(lhs.grid, rhs.grid)
        return Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
    }
    
    static public func - (lhs: Float, rhs: Matrix) -> Matrix {
        let a: [Float] = Array(repeating: lhs, count: rhs.grid.count)
        let v = vDSP.subtract(a, rhs.grid)
        return Matrix(rows: rhs.rows, columns: rhs.columns, values: v)
    }
    
    static public func - (lhs: Matrix, rhs: Float) -> Matrix {
        let a: [Float] = Array(repeating: rhs, count: lhs.grid.count)
        let v = vDSP.subtract(lhs.grid, a)
        return Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
    }
}

extension Matrix: CustomStringConvertible {
    public var description: String {
        var d = ""
        for i in 0..<rows {
            let rowContents = (0..<columns).map { String(format: "%-6.1f", self[i, $0]) }.joined()
            d += rowContents + "\n"
        }
        return d
    }
}

extension Matrix {
    public func writeToTxtFile(name: String, width: Int = 6, sig: Int = 1) {
        var s = ""
        for i in 0..<self.rows {
            let rowContents = (0..<columns).map { String(format: "%-\(width).\(sig)f", self[i, $0]) }.joined()
            s += rowContents + "\n"
        }
        
        let dir = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).last!
        let url = dir.appendingPathComponent("\(name).txt")
        
        do {
            try s.write(toFile: url.path, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }
}
