//
//  ContentView.swift
//  GrayScottColormap
//
//  Created by Gavin Wiggins on 7/24/23.
//

import SwiftUI

struct ResultsView: View {
    
    @Binding var results: [Float]
    let size: CGFloat = 300
    
    var body: some View {
        HStack {
            if results.count > 1 {
                let grayImage = makeGrayImage(from: results, width: Int(size), height: Int(size))
                let viridisImage = makeViridisImage()
                let colormapImage = makeColormapImage(image: grayImage, gradient: viridisImage)
                
                Image(grayImage, scale: 1.0, label: Text("gray image"))
                    .frame(width: size, height: size)
                Image(colormapImage, scale: 1.0, label: Text("colormap image"))
                    .frame(width: size, height: size)
            } else {
                Image(systemName: "photo")
                    .frame(width: size, height: size)
                    .border(.gray)
                Image(systemName: "photo")
                    .frame(width: size, height: size)
                    .border(.gray)
            }
        }
    }
}

struct ContentView: View {
    
    @StateObject private var grayScott = GrayScott()
    @State private var paramF: Float = 0.025
    @State private var paramK: Float = 0.056
    @State private var paramNt: Int = 10_000
    @State private var results: [Float] = [0.0]
    
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                Form {
                    TextField("F, feed rate", value: $paramF, format: .number)
                    TextField("k, rate constant", value: $paramK, format: .number)
                    TextField("nt, total steps", value: $paramNt, format: .number)
                }
                .focusable(false)
                
                Text("Running \(grayScott.step + 1) / \(paramNt)")

                Button("Run simulation") {
                    grayScott.nt = paramNt
                    Task {
                        results = await grayScott.runSimulation(F: paramF, k: paramK)
                    }
                }
            }
            .frame(width: 200)
            
            ResultsView(results: $results)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
