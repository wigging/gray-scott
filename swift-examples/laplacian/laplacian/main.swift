//
//  main.swift
//  laplacian
//
//  Created by Gavin Wiggins on 5/30/23.
//

import Accelerate

/// Pad a matrix with zeros.
/// - Parameter mat: The input matrix.
/// - Returns: A padded matrix with zeros along the border.
func pad(_ mat: Matrix) -> Matrix {
    let shape = (mat.rows + 2) * (mat.columns + 2)
    var c: [Float] = Array(repeating: 0, count: shape)
    
    let m = vDSP_Length(mat.columns)       // number of columns to copy
    let n = vDSP_Length(mat.rows)          // number of rows to copy
    let ta = vDSP_Length(mat.columns)      // number of columns in a
    let tc = vDSP_Length(mat.columns + 2)  // number of columns in c
    
    vDSP_mmov(mat.values, &c[mat.columns + 3], m, n, ta, tc)
    
    return Matrix(rows: mat.rows + 2, columns: mat.columns + 2, values: c)
}

/// Inner matrix of the convolved Laplacian matrix.
/// - Parameters:
///   - v: Values of the convolved matrix.
///   - ncols: Number of columns of the padded matrix.
/// - Returns: Inner matrix.
func inner(_ v: [Float], ncols: Int) -> Matrix {
    let shape = (ncols - 2) * (ncols - 2)
    var c: [Float] = Array(repeating: 0, count: shape)
    
    let m = vDSP_Length(ncols - 2)   // number of columns to copy
    let n = vDSP_Length(ncols - 2)   // number of rows to copy
    let ta = vDSP_Length(ncols)      // number of columns in a
    let tc = vDSP_Length(ncols - 2)  // number of columns in c
    
    let row = 1
    let col = 1
    let s = (row * ncols) + col
    
    vDSP_mmov(Array(v[s...]), &c, m, n, ta, tc)
    
    let mat = Matrix(rows: ncols - 2, columns: ncols - 2, values: c)
    return mat
}

/// Calculate the Laplacian using five-point stencil and periodic boundary conditions.
/// - Parameter m: The input Matrix.
/// - Returns: Laplacian of the input Matrix.
func lap5_convolve(_ m: Matrix) -> Matrix {
    
    let n = m.rows
    
    // create a padded matrix where borders are zero
    var p = pad(m)
    
    // wrap borders for periodic boundary conditions
    for i in 0..<n+2 {
        p[i, 0] = p[i, n]       // left column
        p[i, n+1] = p[i, 1]     // right column
        p[0, i] = p[n, i]       // top row
        p[n+1, i] = p[1, i]     // bottom row
    }

    // solve laplacian using kernel and convolve function
    let k: [Float] = [0,  1, 0,
                      1, -4, 1,
                      0,  1, 0]

    let c = vDSP.convolve(p.values, rowCount: p.rows, columnCount: p.columns, with3x3Kernel: k)
    
    // return inner matrix
    let cm = inner(c, ncols: p.columns)
    return cm
}

/// Calculate the Laplacian using five-point stencil and periodic boundary conditions.
/// - Parameter m: The input Matrix.
/// - Returns: Laplacian of the input Matrix.
func lap5_slices(_ m: Matrix) -> Matrix {
    
    // pad matrix with zeros to create ghost nodes at borders
    var p = pad(m)
    
    // apply periodic boundary conditions by wrapping borders
    for i in 0..<p.rows {
        p[i, 0] = p[i, p.rows-2]    // left column
        p[i, p.rows-1] = p[i, 1]    // right column
        p[0, i] = p[p.rows-2, i]    // top row
        p[p.rows-1, i] = p[1, i]    // bottom row
    }
    
    // five-point stencil
    let left = p[1..<p.rows-1, 0..<p.columns-2]    // shift left for f(x - h, y)
    let right = p[1..<p.rows-1, 2..<p.columns]     // shift right for f(x + h, y)
    let down = p[2..<p.rows, 1..<p.columns-1]      // shift down for f(x, y - h)
    let up = p[0..<p.rows-2, 1..<p.columns-1]      // shift up for f(x, y + h)
    let center = p[1..<p.rows-1, 1..<p.columns-1]  // center for f(x, y)

    // calculate laplacian using five-point stencil
    let lap = left + right + down + up - (4 * center)
    return lap
}

/// Examples of calculating the Laplacian of a matrix using a five-point stencil
/// with periodic boundary conditions.
func main() {
    
    let n: Float = 5  // matrix size as n x n
    
    let a: [Float] = Array(stride(from: 0.0, to: n * n, by: 1.0))
    let m = Matrix(rows: Int(n), columns: Int(n), values: a)
    print("matrix\n\(m)")
    
    let tic1 = CFAbsoluteTimeGetCurrent()
    let result1 = lap5_convolve(m)
    let toc1 = CFAbsoluteTimeGetCurrent()
    let elapsed1 = String(format: "%.4f", toc1 - tic1)
    print("lap5_convolve\n\(result1)")

    let tic2 = CFAbsoluteTimeGetCurrent()
    let result2 = lap5_slices(m)
    let toc2 = CFAbsoluteTimeGetCurrent()
    let elapsed2 = String(format: "%.4f", toc2 - tic2)
    print("lap5_slices\n\(result2)")
    
    print("lap5_convolve, elapsed time \(elapsed1) s")
    print("lap5_slices, elapsed time \(elapsed2) s\n")

    // Example of writing matrix values to text file located on the desktop
    // The data can be loaded with NumPy using np.loadtxt('thedata.txt')
//    let x = Matrix(rows: 5, columns: 5, fill: 0.20498)
//    x.writeToTxtFile(name: "thedata", width: 12, sig: 6)
//    print("x is\n\(x)")
}

main()
