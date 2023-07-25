//
//  ContentView.swift
//  GrayScottCharts
//
//  Created by Gavin Wiggins on 7/24/23.
//

import SwiftUI
import Charts

struct ContentView: View {
    
    @StateObject private var grayScott = GrayScott()
    @State private var paramF: Float = 0.025
    @State private var paramK: Float = 0.056
    
    var body: some View {
        HStack {
            VStack {
                Form {
                    TextField("F, feed rate", value: $paramF, format: .number)
                    TextField("k, rate constant", value: $paramK, format: .number)
                }
                .focusable(false)
                
                Text("Running \(grayScott.step + 1) / \(grayScott.nt)")
                
                Button("Run simulation") {
                    Task {
                        await grayScott.runSimulation(F: paramF, k: paramK)
                    }
                }
            }
            .frame(width: 200)
            
            Chart(grayScott.grid.points) { point in
                RectangleMark(
                    xStart: .value("xStart", point.x),
                    xEnd: .value("xEnd", point.x + 1),
                    yStart: .value("yStart", point.y),
                    yEnd: .value("yEnd", point.y + 1)
                )
                .foregroundStyle(by: .value("Weight", point.val))
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartForegroundStyleScale(range: Gradient(colors: [.black, .red, .yellow, .green, .blue, .purple]))
            .frame(width: 256, height: 256)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
