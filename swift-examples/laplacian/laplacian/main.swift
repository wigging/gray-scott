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
    
    vDSP_mmov(mat.grid, &c[mat.columns + 3], m, n, ta, tc)
    
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

    let c = vDSP.convolve(p.grid, rowCount: p.rows, columnCount: p.columns, with3x3Kernel: k)
    
    // return inner matrix
    let cm = inner(c, ncols: p.columns)
    return cm
}

/// Example of calculating the Laplacian of a matrix using a five-point stencil
/// with periodic boundary conditions.
func main() {
    
    let n: Float = 5.0  // matrix size as n x n
    
    let a: [Float] = Array(stride(from: 0.0, to: n * n, by: 1.0))
    let m = Matrix(rows: Int(n), columns: Int(n), values: a)
    print("m is\n\(m)")

    let lap = lap5_convolve(m)
    print("lap is\n\(lap)")
    
    // example of writing matrix values to text file on the desktop
    // the data can be loaded with NumPy using np.loadtxt('thedata.txt')
    let x = Matrix(rows: 5, columns: 5, fill: 0.20498)
    x.writeToTxtFile(name: "thedata", width: 12, sig: 6)
    print("x is\n\(x)")
}

main()
