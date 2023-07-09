//
//  GrayScott.swift
//  grayscott-macos
//
//  Created by Gavin Wiggins on 6/12/23.
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

class GrayScott: ObservableObject {
    
    @Published var grid = Grid(rows: 256, columns: 256)
    @Published var step = 0
    
    let nt = 10000 // number of time steps
    
    func runSimulation(F: Float, k: Float) async {

        let Du: Float = 0.2    // diffusion coefficient for U
        let Dv: Float = 0.1    // diffusion coefficient for V
        
        let n = 256            // grid size n x n, try a value of 128 or 256
        let dt: Float = 1      // time step
        
        // initialize matrices
        var U = Matrix(rows: n, columns: n, fill: 1)
        var V = Matrix(rows: n, columns: n, fill: 0)
        
        // initial concentrations at center
        let low = Int(n / 2) - 9
        let high = Int(n / 2) + 10

        for i in low..<high {
            for j in low..<high {
                U[i, j] = 0.5 + Float.random(in: 0..<0.1)
                V[i, j] = 0.25 + Float.random(in: 0..<0.1)
            }
        }
        
        // solve at each time step
        for nstep in 0..<nt {
            await MainActor.run {
                step = nstep
            }
            
            let UVV = U * V * V
            let lapU = lap5_convolve(U)
            let lapV = lap5_convolve(V)
            
            U = U + (Du * lapU - UVV + F * (1 - U)) * dt
            V = V + (Dv * lapV + UVV - (F + k) * V) * dt
        }
        
        print("Min U is \(U.grid.min()!)")
        print("Max U is \(U.grid.max()!)")
        print("Done.")
        
        // generate grid of points for chart
        let uMatrix = U
        await MainActor.run {
            grid.generateData(matrix: uMatrix)
        }
    }
}
