import Foundation

struct Matrix {

    let rows: Int
    let columns: Int
    var grid: [Double]

    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: 0.0, count: rows * columns)
    }

    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }

    subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }

    func display() {
        for i in 0..<rows {
            for j in 0..<columns {
                print(grid[(i * columns) + j], terminator: "\t")
            }
            print("")
        }
    }
}

// Example usage
let nrows = 5
let ncols = 5
var a = Matrix(rows: nrows, columns: ncols)

a[(nrows / 2) - 1, (ncols / 2) - 1] = 11
a[(nrows / 2) - 1, (ncols / 2)] = 22
a[(nrows / 2) - 1, (ncols / 2) + 1] = 33

a[nrows / 2, (ncols / 2) - 1] = 44
a[nrows / 2, ncols / 2] = 55

a.display()
