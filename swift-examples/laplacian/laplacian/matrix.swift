//
//  matrix.swift
//  laplacian
//
//  Created by Gavin Wiggins on 5/30/23.
//

import Accelerate

public struct Matrix {
    
    let rows: Int
    let columns: Int
    var values: [Float]
        
    public init(rows: Int, columns: Int, fill: Float = 0) {
        self.rows = rows
        self.columns = columns
        self.values = Array(repeating: fill, count: rows * columns)
    }
        
    public init(rows: Int, columns: Int, values: [Float]) {
        self.rows = rows
        self.columns = columns
        self.values = values
    }
    
    public init(_ array2d: [[Float]]) {
        self.rows = array2d.count
        self.columns = array2d[0].count
        self.values = array2d.flatMap { $0 }
    }
    
    public subscript(row: Int, column: Int) -> Float {
        get { return values[(row * columns) + column] }
        set { values[(row * columns) + column] = newValue }
    }
    
    public subscript(rows: Range<Int>, columns: Range<Int>) -> Matrix {
        get {
            let nrows = rows.upperBound - rows.lowerBound
            let ncols = columns.upperBound - columns.lowerBound
            var c: [Float] = Array(repeating: 0, count: nrows * ncols)
            
            let m = vDSP_Length(ncols)         // number of columns to copy
            let n = vDSP_Length(nrows)         // number of rows to copy
            let ta = vDSP_Length(self.columns) // number of columns in a
            let tc = vDSP_Length(ncols)        // number of columns in c
            
            let idx = (rows.lowerBound * self.columns) + columns.lowerBound
            let a = Array(self.values[idx...])
            
            vDSP_mmov(a, &c, m, n, ta, tc)
            
            let mat = Matrix(rows: nrows, columns: ncols, values: c)
            return mat
        }
    }
    
    static public func * (lhs: Matrix, rhs: Matrix) -> Matrix {
        let v = vDSP.multiply(lhs.values, rhs.values)
        let m = Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
        return m
    }
    
    static public func * (lhs: Float, rhs: Matrix) -> Matrix {
        let v = vDSP.multiply(lhs, rhs.values)
        let m = Matrix(rows: rhs.rows, columns: rhs.columns, values: v)
        return m
    }
    
    static public func * (lhs: Matrix, rhs: Float) -> Matrix {
        let v = vDSP.multiply(rhs, lhs.values)
        let m = Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
        return m
    }
    
    static public func / (lhs: Matrix, rhs: Float) -> Matrix {
        let v = vDSP.divide(lhs.values, rhs)
        let m = Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
        return m
    }
    
    static public func + (lhs: Matrix, rhs: Matrix) -> Matrix {
        let v = vDSP.add(lhs.values, rhs.values)
        return Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
    }

    static public func + (lhs: Float, rhs: Matrix) -> Matrix {
        let v = vDSP.add(lhs, rhs.values)
        return Matrix(rows: rhs.rows, columns: rhs.columns, values: v)
    }
    
    static public func + (lhs: Matrix, rhs: Float) -> Matrix {
        let v = vDSP.add(rhs, lhs.values)
        return Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
    }
    
    static public func - (lhs: Matrix, rhs: Matrix) -> Matrix {
        let v = vDSP.subtract(lhs.values, rhs.values)
        return Matrix(rows: lhs.rows, columns: lhs.columns, values: v)
    }
    
    static public func - (lhs: Float, rhs: Matrix) -> Matrix {
        let a: [Float] = Array(repeating: lhs, count: rhs.values.count)
        let v = vDSP.subtract(a, rhs.values)
        return Matrix(rows: rhs.rows, columns: rhs.columns, values: v)
    }
    
    static public func - (lhs: Matrix, rhs: Float) -> Matrix {
        let a: [Float] = Array(repeating: rhs, count: lhs.values.count)
        let v = vDSP.subtract(lhs.values, a)
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
