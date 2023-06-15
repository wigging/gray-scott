//
//  Grid.swift
//  grayscott-macos
//
//  Created by Gavin Wiggins on 6/13/23.
//

import Foundation
import SwiftUI

struct Point: Hashable, Identifiable {
    
    let id = UUID()
    let x: Int
    let y: Int
    let val: Float

    var color: Color {
        switch val {
        case 0.0..<0.25:
            return Color(red: 116/255, green: 0/255, blue: 184/255)
        case 0.25..<0.3:
            return Color(red: 105/255, green: 48/255, blue: 195/255)
        case 0.3..<0.35:
            return Color(red: 94/255, green: 96/255, blue: 206/255)
        case 0.35..<0.4:
            return Color(red: 83/255, green: 144/255, blue: 217/255)
        case 0.4..<0.5:
            return Color(red: 78/255, green: 168/255, blue: 222/255)
        case 0.5..<0.55:
            return Color(red: 72/255, green: 191/255, blue: 227/255)
        case 0.55..<0.6:
            return Color(red: 86/255, green: 207/255, blue: 225/255)
        case 0.6..<0.65:
            return Color(red: 100/255, green: 223/255, blue: 223/255)
        case 0.65..<0.7:
            return Color(red: 114/255, green: 239/255, blue: 221/255)
        case 0.7...1.0:
            return Color(red: 128/255, green: 255/255, blue: 219/255)
        default:
            return Color(red: 128/255, green: 255/255, blue: 219/255)
        }
    }
}

/*
 Colormap (RGB) https://coolors.co/7400b8-6930c3-5e60ce-5390d9-4ea8de-48bfe3-56cfe1-64dfdf-72efdd-80ffdb
 0.0..<0.1 - 116, 0, 184
 0.1..<0.2 - 105, 48, 195
 0.2..<0.3 - 94, 96, 206
 0.3..<0.4 - 83, 144, 217
 0.4..<0.5 - 78, 168, 222
 0.5..<0.6 - 72, 191, 227
 0.6..<0.7 - 86, 207, 225
 0.7..<0.8 - 100, 223, 223
 0.8..<0.9 - 114, 239, 221
 0.9...1.0 - 128, 255, 219
 */

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
