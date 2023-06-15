//
//  ContentView.swift
//  grayscott-macos
//
//  Created by Gavin Wiggins on 6/12/23.
//

import SwiftUI
import Charts

struct ContentView: View {
    
    @StateObject private var grayScott = GrayScott()
    
    var body: some View {
        VStack {
            Chart(grayScott.grid.points) { point in
                RectangleMark(
                    xStart: .value("xStart", point.x),
                    xEnd: .value("xEnd", point.x + 1),
                    yStart: .value("yStart", point.y),
                    yEnd: .value("yEnd", point.y + 1)
                )
                .foregroundStyle(point.color)
            }
            .padding()
            
            Text("Running \(grayScott.step + 1) / \(grayScott.nt)")
            
            Button("Run simulation") {
                Task {
                    await grayScott.runSimulation()
                }
            }
        }
        .padding()
        .frame(width: 500, height: 500)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
