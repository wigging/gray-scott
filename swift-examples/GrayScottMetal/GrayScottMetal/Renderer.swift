//
//  Renderer.swift
//  GrayScottMetal
//
//  Created by Gavin Wiggins on 9/4/23.
//

import MetalKit

class Renderer: NSObject {

    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!

    var drawState: MTLComputePipelineState!
    var grayscottState: MTLComputePipelineState!
    
    var uBuffer: MTLBuffer!
    var vBuffer: MTLBuffer!
    var unewBuffer: MTLBuffer!
    var vnewBuffer: MTLBuffer!
    var colormapBuffer: MTLBuffer!
    var paramsBuffer: MTLBuffer!
        
    var params: Parameters

    init(metalView: MTKView, params: Parameters) {
        self.params = params
        
        super.init()
        
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue()
        else {
            fatalError("GPU device not available")
        }

        Renderer.device = device
        Renderer.commandQueue = commandQueue

        let library = device.makeDefaultLibrary()
        let drawShader = library?.makeFunction(name: "draw")
        let grayscottShader = library?.makeFunction(name: "grayscott")

        do {
            drawState = try device.makeComputePipelineState(function: drawShader!)
            grayscottState = try device.makeComputePipelineState(function: grayscottShader!)
        } catch let error as NSError {
            print(error)
        }

        metalView.device = device
        metalView.framebufferOnly = false
        metalView.delegate = self
        
        makeBuffers()
    }
    
    func makeBuffers() {
        
        let width = Int(params.width)
        let height = Int(params.height)

        // initialize matrices
        var U = Matrix(rows: height, columns: width, fill: 1)
        var V = Matrix(rows: height, columns: width, fill: 0)
        let Unew = Matrix(rows: height, columns: width, fill: 1)
        let Vnew = Matrix(rows: height, columns: width, fill: 0)
        
        // initial concentrations at center
        let low = Int(height - 50) - 9
        let high = Int(height - 50) + 10

        for i in low..<high {
            for j in low..<high {
                U[i, j] = 0.5 + Float.random(in: 0..<0.1)
                V[i, j] = 0.25 + Float.random(in: 0..<0.1)
            }
        }
                
        uBuffer = Renderer.device.makeBuffer(bytes: U.grid, length: MemoryLayout<Float>.stride * U.grid.count)
        vBuffer = Renderer.device.makeBuffer(bytes: V.grid, length: MemoryLayout<Float>.stride * V.grid.count)
        unewBuffer = Renderer.device.makeBuffer(bytes: Unew.grid, length: MemoryLayout<Float>.stride * Unew.grid.count)
        vnewBuffer = Renderer.device.makeBuffer(bytes: Vnew.grid, length: MemoryLayout<Float>.stride * Vnew.grid.count)
        
        let cmap = Array(colormap.reversed())
        colormapBuffer = Renderer.device.makeBuffer(bytes: cmap, length: MemoryLayout<SIMD3<Float>>.stride * 256)
        
        paramsBuffer = Renderer.device.makeBuffer(bytes: &params, length: MemoryLayout<Parameters>.stride)
    }
}

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    
    func compute() {
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        commandEncoder?.setComputePipelineState(grayscottState)
        commandEncoder?.setBuffer(uBuffer, offset: 0, index: 0)
        commandEncoder?.setBuffer(vBuffer, offset: 0, index: 1)
        commandEncoder?.setBuffer(unewBuffer, offset: 0, index: 2)
        commandEncoder?.setBuffer(vnewBuffer, offset: 0, index: 3)
        commandEncoder?.setBuffer(paramsBuffer, offset: 0, index: 4)

        let threadsPerGrid = MTLSize(width: Int(params.width), height: Int(params.height), depth: 1)
        let w = grayscottState.threadExecutionWidth
        let h = grayscottState.maxTotalThreadsPerThreadgroup / w
        let threadsPerGroup = MTLSize(width: w, height: h, depth: 1)

        commandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder?.endEncoding()
        
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
        
        // Update U and V buffers for next time step
        uBuffer = unewBuffer
        vBuffer = vnewBuffer
    }

    func draw(in view: MTKView) {
        
        for _ in 0..<10 {
            compute()
        }
                        
        guard let drawable = view.currentDrawable else { return }

        let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()

        commandEncoder?.setComputePipelineState(drawState)
        commandEncoder?.setBuffer(unewBuffer, offset: 0, index: 0)
        commandEncoder?.setBuffer(colormapBuffer, offset: 0, index: 1)
        commandEncoder?.setTexture(drawable.texture, index: 0)

        let threadsPerGrid = MTLSize(width: Int(params.width), height: Int(params.height), depth: 1)
        let w = drawState.threadExecutionWidth
        let h = drawState.maxTotalThreadsPerThreadgroup / w
        let threadsPerGroup = MTLSize(width: w, height: h, depth: 1)

        commandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
