//
//  Grid.swift
//  GrayScottCharts
//
//  Created by Gavin Wiggins on 7/24/23.
//

import SwiftUI

struct Point: Hashable, Identifiable {
    let id = UUID()
    let x: Int
    let y: Int
    let val: Float
}

struct Grid {
    
    let rows: Int
    let columns: Int
    var points = [Point]()
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
    }
    
    mutating func generateData(matrix: Matrix) {
        for i in 0..<rows {
            for j in 0..<columns {
                let v = matrix[i, j]
                let point = Point(x: j, y: i, val: v)
                points.append(point)
            }
        }
    }
}
