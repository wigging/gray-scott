//
//  main.swift
//  ex1-loops
//
//  Created by Gavin Wiggins on 5/27/23.
//

func laplace(f: inout Matrix, h2: Float) -> Matrix {
    let n = 22
    for i in 1..<n-1 {
        for j in 1..<n-1 {
            f[i, j] = (f[i-1, j] + f[i+1, j] + f[i, j-1] + f[i, j+1] - 4 * f[i, j]) / h2
        }
    }
    return f
}

func main() {

    let Du: Float = 0.2    // diffusion coefficient for U
    let Dv: Float = 0.1    // diffusion coefficient for V
    let F: Float = 0.025   // feed rate
    let k: Float = 0.056   // rate constant

    let n = 20             // grid size n x n, try a value of 128 or 256
    let h: Float = 1       // grid spacing

    let nt = 10000         // number of time steps
    let dt: Float = 1      // time step

    // initialize arrays with borders as ghost nodes
    let nn = n + 2
    var U = Matrix(rows: nn, columns: nn, fill: 1)
    var V = Matrix(rows: nn, columns: nn)

    // initial concentrations at center
    let low = Int(nn / 2) - 9
    let high = Int(nn / 2) + 10

    // initial concentrations at center
    for i in low..<high {
        for j in low..<high {
            U[i, j] = 0.5 + Float.random(in: 0..<0.1)
            V[i, j] = 0.25 + Float.random(in: 0..<0.1)
        }
    }

    // solve at each time step
    for n in 0..<nt {
        print("Running \(n+1)/\(nt)", terminator: "\r")
        
        let UVV = U * V * V
        let lapU = laplace(f: &U, h2: Float(h * h))
        let lapV = laplace(f: &V, h2: Float(h * h))

        U = U + (Du * lapU - UVV + F * (1 - U)) * dt
        V = V + (Dv * lapV + UVV - (F + k) * V) * dt
        
        // apply periodic boundary conditions
        for k in 0..<nn {
            U[0, k] = U[nn-2, k]
            U[k, 0] = U[k, nn-2]
            U[nn-1, k] = U[1, k]
            U[k, nn-1] = U[k, 1]
            
            V[0, k] = V[nn-2, k]
            V[k, 0] = V[k, nn-2]
            V[nn-1, k] = V[1, k]
            V[k, nn-1] = V[k, 1]
        }
    }
}

main()
