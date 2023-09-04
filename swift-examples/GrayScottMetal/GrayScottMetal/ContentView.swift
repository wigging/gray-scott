//
//  ContentView.swift
//  GrayScottMetal
//
//  Created by Gavin Wiggins on 9/4/23.
//

import SwiftUI
import MetalKit

struct Parameters {
    var F: Float                // dimensionless feed rate
    var k: Float                // dimensionless rate constant
    let Du: Float = 0.2         // diffusion coefficient for U
    let Dv: Float = 0.1         // diffusion coefficient for V
    let width: UInt32 = 800     // 2x frame width of the SwiftUI view
    let height: UInt32 = 600    // 2x frame height of the SwiftUI view
}

struct Preset {
    let title: String
    let F: Float
    let k: Float
}

struct ContentView: View {
    
    private let presets = [
        Preset(title: "α", F: 0.010, k: 0.047),
        Preset(title: "β", F: 0.026, k: 0.051),
        Preset(title: "γ", F: 0.025, k: 0.056),
        Preset(title: "δ", F: 0.042, k: 0.059),
        Preset(title: "ε", F: 0.022, k: 0.059),
        Preset(title: "ζ", F: 0.026, k: 0.059),
        Preset(title: "η", F: 0.034, k: 0.063),
        Preset(title: "θ", F: 0.030, k: 0.057),
        Preset(title: "ι", F: 0.046, k: 0.0594),
        Preset(title: "κ", F: 0.058, k: 0.063),
        Preset(title: "λ", F: 0.026, k: 0.061),
        Preset(title: "μ", F: 0.046, k: 0.065)
    ]
    
    @State private var selection = 0
    @State private var mtkView = MTKView()
    @State private var renderer: Renderer?

    var body: some View {
        VStack {
            MetalView(mtkView: mtkView)
                .frame(width: 400, height: 300)
                .onAppear {
                    let i = selection
                    let p = Parameters(F: presets[i].F, k: presets[i].k)
                    renderer = Renderer(metalView: mtkView, params: p)
                }
            
            HStack {
                Picker("Presets", selection: $selection) {
                    ForEach(presets.indices, id: \.self) { i in
                        Text(presets[i].title)
                    }
                }
                .onChange(of: selection) { i in
                    let p = Parameters(F: presets[i].F, k: presets[i].k)
                    renderer?.params = p
                    renderer?.makeBuffers()
                }
                .frame(width: 110)
            
                Text("F = \(String(format: "%.3f", presets[selection].F))")
                Text("k = \(String(format: "%.3f", presets[selection].k))")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
