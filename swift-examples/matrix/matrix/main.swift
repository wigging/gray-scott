//
//  main.swift
//  matrix
//
//  Created by Gavin Wiggins on 5/27/23.
//

func runInitializationExamples() {
    print("--- Initialization ---\n")
    
    // Example 1
    let m1 = Matrix(rows: 2, columns: 3)
    print(m1)

    // Example 2
    let m2 = Matrix(rows: 2, columns: 3, fill: 4.1)
    print(m2)

    // Example 3
    let a3: [Float] = [1, 2, 3,
                       4, 5, 6]
    let m3 = Matrix(rows: 2, columns: 3, values: a3)
    print(m3)

    // Example 4
    let a4: [[Float]] = [[8, 9, 10], [1, 2, 3]]
    let m4 = Matrix(a4)
    print(m4)
}

func runAssignValue() {
    print("--- Assign value ---\n")

    var m = Matrix(rows:4, columns:5)
    m[1, 1] = 99.1
    print(m)
}

func runMultiplication() {
    print("--- Multiplication ---\n")
    
    // Example 1
    let a1 = Matrix([[1, 2, 3],
                     [4, 5, 6]])
    let b1 = Matrix([[3, 4, 5],
                     [5, 6, 7]])
    print(a1 * b1)

    // Example 2
    let a2 = Matrix([[1, 2, 3],
                     [4, 5, 6]])
    let b2 = Matrix([[3, 4, 5],
                     [5, 6, 7]])
    let c2 = Matrix([[2, 3, 5],
                     [5, 6, 8]])
    print(a2 * b2 * c2)
    
    // Example 3 where Scalar x Matrix
    let a3: Float = 0.5
    let b3 = Matrix([[3, 4, 5],
                     [5, 6, 7]])
    print(a3 * b3)
    
    // Example 4 where Matrix x Scalar
    let a4 = Matrix([[3, 4, 5],
                     [5, 6, 7]])
    let b4: Float = 0.5
    print(a4 * b4)
}

func runDivision() {
    print("--- Division ---\n")
    
    let a = Matrix([[3, 4, 5],
                    [5, 6, 7]])
    let b: Float = 2
    print(a / b)
}

func runAddition() {
    print("--- Addition ---\n")
    
    // Example 1
    let a = Matrix([[1, 2, 3],
                    [4, 5, 6]])
    let b = Matrix([[3, 4, 5],
                    [5, 6, 7]])
    print(a + b)
    
    // Example 2
    let a2 = Matrix([[3, 4, 5],
                    [5, 6, 7]])
    let b2: Float = 2.9
    print(a2 + b2)

    // Example 3
    let a3 = Matrix([[3, 4, 5],
                    [5, 6, 7]])
    let b3: Float = 2.9
    print(b3 + a3)
}

func runSubtraction() {
    print("--- Subtraction ---\n")
    
    // Example 1
    let a1 = Matrix([[11, 2, 3],
                    [4, 5, 16]])
    let b1 = Matrix([[3, 4, 5],
                    [5, 6, 7]])
    print(a1 - b1)
    
    // Example 2
    let a2 = Matrix([[3, 4, 5],
                    [5, 6, 7]])
    let b2: Float = 2.9
    print(a2 - b2)

    // Example 3
    let a3 = Matrix([[3, 4, 5],
                    [5, 6, 7]])
    let b3: Float = 2.9
    print(b3 - a3)
}

func runLoop() {
    print("--- Loop ---\n")
    let a = Matrix([[1, 2, 3, 4],
                    [5, 6, 7, 8],
                    [9, 5, 6, 2]])

    for i in 0..<3 {
        for j in 0..<4 {
            print("a[\(i), \(j)] is \(a[i, j])")
        }
        print("")
    }
}

runInitializationExamples()
runAssignValue()
runMultiplication()
runDivision()
runAddition()
runSubtraction()
runLoop()
