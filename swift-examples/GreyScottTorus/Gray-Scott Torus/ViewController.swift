import MetalKit

struct SceneConstants { var projectionMatrix = matrix_identity_float4x4 }
struct ModelConstants { var modelViewMatrix = matrix_identity_float4x4 }

class ViewController: NSViewController, MTKViewDelegate {

	var metalKitView: MTKView!
	var devices: [MTLDevice] = []
	var device: MTLDevice!
	var commandQueue: MTLCommandQueue!
	var library: MTLLibrary!
	var pipelineState: MTLRenderPipelineState!
	var depthStencilState: MTLDepthStencilState!
	var computePipelineState: MTLComputePipelineState!
	var meshBuffer, uBuffer, uNextBuffer, vBuffer, vNextBuffer: MTLBuffer!
	
	let fragmentName = "fragmentShader"
	let vertexName = "vertexShader"
	let computeName = "grayScottCore"
	
	let defaults = UserDefaults.standard
	let savedParamsKey = "SavedParameters"
	var sceneConstants = SceneConstants()
	var planeConstants = ModelConstants()
	var triangleCount = 0, vertexCount = 0, cellCount = 0
	
	var time: Float = 0
	var scheme: Int = 0
	var topology: Int = 1
	var topologyOld: Int = 1
	var interpolate: Float = 1
	var running: Bool = true
	var timer: Timer!
	var timerFiring = true
	var wing = 100
	var steps = 0
	var frameCounter = 0
	var computeCounter = 0
	var computeFrequency = 0.0
	var lastDate = Date()
	var usingSavedItem = false
	var savedParameters: [(Float, Float)] = []
	let sigfigFactor: Float = 100_000
	var fill = true
	
	var F: Float = 0.025
	var k: Float = 0.056
	var Du: Float = 0.2
	var Dv: Float = 0.1

	@objc dynamic var FF: Float {
		set {
			F = newValue
			updateSaveButton()
		}
		get {
			F
		}
	}
	@objc dynamic var kk: Float {
		set {
			k = newValue
			updateSaveButton()
		}
		get {
			k
		}
	}
	
	// MARK: - User Interactions -
	
	@IBOutlet weak var label: NSTextField!
	@IBOutlet weak var fillLabel: NSButton!
	@IBOutlet weak var colorMenu: NSPopUpButton!
	@IBOutlet weak var startStopButton: NSButton!
	@IBOutlet weak var openMenu: NSPopUpButton!
	@IBOutlet weak var toposMenu: NSPopUpButton!
	@IBOutlet weak var saveButton: NSButton!
	
	@IBAction func startStop(_ sender: Any) {
		running = !running
		
		startStopButton.title = running ? "Pause" : "Run"
	}
	
	@IBAction func changeColorScheme(_ sender: NSPopUpButton) {
		if sender.indexOfSelectedItem != scheme {
			scheme = sender.indexOfSelectedItem
		}
	}
	
	@IBAction func changeTopology(_ sender: NSPopUpButton) {
		if sender.indexOfSelectedItem != topology {
			interpolate = 0
			topologyOld = topology
			topology = sender.indexOfSelectedItem
		}
	}
	
	@IBAction func changeFill(_ sender: NSButton) {
		fill = (sender.state == .on)
	}
	
	@IBAction func gridChange(_ sender: NSSlider) {
		wing = Int(sender.intValue)
		setupModels()
		updateLabel()
		
		if !timerFiring {
			timer.fire()
		}
	}
	
	@IBAction func save(_ sender: Any) {
		let F₁ = Float(Int(F * sigfigFactor)) / sigfigFactor
		let k₁ = Float(Int(k * sigfigFactor)) / sigfigFactor
		let whereClause = { (a, b) in (a, b) == (F₁, k₁) }
		
		if usingSavedItem {
			savedParameters.removeAll(where: whereClause)
			
			if !savedParameters.isEmpty {
				let param = savedParameters[0]
				F = param.0
				k = param.1
			}
			
			reset("")
		}
		else {
			if savedParameters.contains(where: whereClause) {
				return // safety check, probably unneeded
			}
			else {
				savedParameters.append((F₁, k₁))
			}
		}
		
		updateSavedMenu()
	}
	
	@IBAction func open(_ sender: NSPopUpButton) {
		let request = sender.indexOfSelectedItem
		
		if request <= savedParameters.count {
			usingSavedItem = true
			let param = savedParameters[sender.indexOfSelectedItem - 1]
			FF = param.0
			kk = param.1
			updateSaveButton()
			reset("")
		}
	}
	
	@IBAction func reset(_ sender: Any) {
		running = true
		startStopButton.title = "Pause"
		setupModels()
		updateLabel()
		
		if !timerFiring {
			timer.fire()
		}
		
	}
	
	// MARK: - General Setup -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		toposMenu.selectItem(at: 1)
		
		loadSavedItems()
		fixFillLabelColor()
		initialMetalSetup()
		fullMetalReset()
		
		timer = Timer.scheduledTimer(withTimeInterval: 0, repeats: true) { _ in
			self.compute()
			self.blit()
			self.computeCounter += 1
		}
		
		reset("")
	}
	
	func updateSaveButton() {
		usingSavedItem = false
		
		openMenu.selectItem(at: 0)
		let title = openMenuTitle(forParameter: (F, k))
		
		if let item = openMenu.item(withTitle: title) {
			openMenu.select(item)
			usingSavedItem = true
		}
		
		saveButton.title = usingSavedItem ? "Delete" : "Save"
	}
	
	func sortSavedParameters() {
		savedParameters.sort(by: { a, b in (a.0 == b.0) ? (a.1 < b.1) : (a.0 < b.0) })
	}
	
	func openMenuTitle(forParameter z: (Float, Float)) -> String {
		let F₁ = Float(Int(z.0 * sigfigFactor)) / sigfigFactor
		let k₁ = Float(Int(z.1 * sigfigFactor)) / sigfigFactor
		
		return "F: \(F₁), k: \(k₁)"
	}
	
	func updateSavedMenu() {
		sortSavedParameters()
		openMenu.removeAllItems()
		openMenu.addItem(withTitle: "")
		
		let toSave = savedParameters.map { [$0.0 as NSNumber, $0.1 as NSNumber] }
		
		defaults.setValue(toSave, forKey: savedParamsKey)
		
		for param in savedParameters {
			openMenu.addItem(withTitle: openMenuTitle(forParameter: param))
		}
		
		updateSaveButton()
	}
	
	func loadSavedItems() {
		if let savedParams = defaults.value(forKey: savedParamsKey) as? [[NSNumber]] {
			savedParameters = savedParams.map { (Float(truncating: $0[0]), Float(truncating: $0[1])) }
		}
		
		updateSavedMenu()
	}
	
	func populateSavedMenu() {
		openMenu.removeAllItems()
		
		for item in savedParameters {
			openMenu.addItem(withTitle: "F = \(item.0), k = \(item.1)")
		}
	}
	
	func fixFillLabelColor() {
		let colorTitle = NSMutableAttributedString(attributedString: fillLabel.attributedTitle)
		colorTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.yellow, range: NSMakeRange(0, colorTitle.length))
		fillLabel.attributedTitle = colorTitle
	}
	
	// MARK: - Metal Setup -
	
	func fullMetalReset() {
		setupMetal()
		setupView()
		setupPipeline()
		setupModels()
		updateLabel()
		setupConstants()
	}
	
	func initialMetalSetup() {
		device = MTLCopyAllDevices()[0]
	}
	
	func setupMetal() {
		commandQueue = device.makeCommandQueue()
		library = device.makeDefaultLibrary()
	}
	
	func setupView() {
		guard let mView = view as? MTKView else {
			fatalError("💔 Unable to set up metalKitView")
		}
		mView.delegate = self
		mView.device = device
		mView.colorPixelFormat = .bgra8Unorm
		mView.depthStencilPixelFormat = .depth32Float
		
		metalKitView = mView
	}
	
	func updateLabel() {
		let side = 2 * wing
		
		label.stringValue = "\(side) × \(side) grid           triangleCount: \(readableNumber(triangleCount))           vertexCount: \(readableNumber(vertexCount))           compute frequency: \(!running ? "—" : "\(Double(Int(computeFrequency / 100))/10)") kHz           steps: \(readableNumber(steps))"
	}
	
	func setupPipeline() {
		if
			let fragmentKernel = library.makeFunction(name: fragmentName),
			let vertexKernel = library.makeFunction(name: vertexName),
			let computeKernel = library.makeFunction(name: computeName) {
			
			let pipelineDescriptor = MTLRenderPipelineDescriptor()
			pipelineDescriptor.vertexFunction = vertexKernel
			pipelineDescriptor.fragmentFunction = fragmentKernel
			pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
			pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
			
			do {
				pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
			}
			catch let error as NSError {
				fatalError("💔 Error: \(error.localizedDescription)")
			}
			
			let depthStateDescriptor = MTLDepthStencilDescriptor()
			depthStateDescriptor.depthCompareFunction = .less
			depthStateDescriptor.isDepthWriteEnabled = true
			depthStencilState = device.makeDepthStencilState(descriptor: depthStateDescriptor)
			
			do {
				computePipelineState = try device.makeComputePipelineState(function: computeKernel)
			}
			catch let error as NSError {
				fatalError("💔 Error: \(error.localizedDescription)")
			}
		}
		else {
			fatalError("💔 Kernel functions not found at runtime")
		}
	}
	
	func setupModels() {
		steps = 0
		
		// This runs slow in debug mode, but very fast in run builds
		
		let α = π / Float(wing)
		let side = 2 * wing
		
		//___________________________________________________ vertices
		
		cellCount = side * side
		vertexCount = 6 * cellCount
		triangleCount = 2 * cellCount
		
		/*  +--+--+--+...   but composed of triangles with overlapping edges:
			| /| /| /|
		    |/ |/ |/ |      +--+      +     +--+
		    +--+--+--+...   | /  +   /|  +  | /  +  ...
		    | /| /| /|      |/      / |     |/
		    |/ |/ |/ |      +      +--+     +
		    +--+--+--+...
		 */
		
		var vertices = [float2](repeating: float2(repeating: 0), count: vertexCount)
		
		var i = 0
		
		for x in -wing ..< wing {
			for y in -wing ..< wing {
				vertices[i+0] = α * float2(Float(x  ), Float(y  )) // Δ₁
				vertices[i+1] = α * float2(Float(x+1), Float(y  ))
				vertices[i+2] = α * float2(Float(x  ), Float(y+1))
				
				vertices[i+3] = α * float2(Float(x+1), Float(y  )) // Δ₂
				vertices[i+4] = α * float2(Float(x  ), Float(y+1))
				vertices[i+5] = α * float2(Float(x+1), Float(y+1))
				
				i += 6
			}
		}
		
//		let x = (0 ..< (side*side)).map { "cell #\($0) ::: (\(Int(vertices[6 * $0].x)), \(Int(vertices[6 * $0].y))) ↔︎ (\(Int(vertices[6 * $0 + 1].x)), \(Int(vertices[6 * $0 + 1].y))) ↔︎ (\(Int(vertices[6 * $0 + 2].x)), \(Int(vertices[6 * $0 + 2].y)))    |||     (\(Int(vertices[6 * $0 + 3].x)), \(Int(vertices[6 * $0 + 3].y))) ↔︎ (\(Int(vertices[6 * $0 + 4].x)), \(Int(vertices[6 * $0 + 4].y))) ↔︎ (\(Int(vertices[6 * $0 + 5].x)), \(Int(vertices[6 * $0 + 5].y)))"}.joined(separator: "\n")
		
		meshBuffer = device.makeBuffer(bytes: vertices, length: vertexCount * MemoryLayout<float2>.size, options: .storageModeShared)
		
		//___________________________________________________ cells -- this part is SLOW!
	
		let length = cellCount * MemoryLayout<Float>.size
		var uCells = [Float](repeating: 1, count: cellCount)
		var vCells = [Float](repeating: 0, count: cellCount)
		
		uNextBuffer = device.makeBuffer(bytes: uCells, length: length, options: .storageModeShared)
		vNextBuffer = device.makeBuffer(bytes: vCells, length: length, options: .storageModeShared)
		
		for i in 0 ..< 5 {
			for j in 0 ..< 5 {
				let o = (side / 2 - 2)
				let n = (j + o) * side + i + o
				uCells[n] = 0.5 + Float.random(in: 0...0.1)
				vCells[n] = 0.25 + Float.random(in: 0...0.1)
			}
		}
		
		uBuffer = device.makeBuffer(bytes: uCells, length: length, options: .storageModeShared)
		vBuffer = device.makeBuffer(bytes: vCells, length: length, options: .storageModeShared)
	}
	
	func setupConstants() {
		let viewMatrix = matrix_float4x4(translationX: 0, y: 0, z: -8)
		let modelMatrix = matrix_float4x4(rotationAngle: 1.1, x: 1, y: 0, z: 0)
		
		planeConstants.modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
		sceneConstants.projectionMatrix = matrix_float4x4(projectionFov: 1.1, aspect: 1.2, nearZ: 0.0001, farZ: 100)
	}
	
	// MARK: - Render Time -
	
	public func draw(in view: MTKView) {
		update()
		
		if frameCounter % 60 == 0 {
			updateLabel()
			let Δt = Date().timeIntervalSince(lastDate)
			computeFrequency = Double(computeCounter) / Δt
			computeCounter = 0
			lastDate = Date()
		}
		frameCounter += 1

		render()
	}
	
	func update() {
		time += 0.005
		
		let viewMatrix = planeConstants.modelViewMatrix
		let modelMatrix = matrix_float4x4(rotationAngle: 0.002, x: 0, y: 0, z: 1)
		planeConstants.modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
	}
	
	func compute() {
		if !running { return }
		
		guard let commandBuffer = commandQueue.makeCommandBuffer(),
			  let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
		
		steps += 1
		
		let threadgroupWidth = 8
		var side = 2 * wing
		let μ = side / threadgroupWidth + (side == threadgroupWidth ? 0 : 1)
		
		let threadgroups = MTLSize(width: μ, height: μ, depth: 1)
		let threadsPerThreadgroup = MTLSize(width: threadgroupWidth, height: threadgroupWidth, depth: 1)
		
		computeEncoder.setComputePipelineState(computePipelineState)
		
		computeEncoder.setBytes(&side, length: MemoryLayout<Int  >.size, index: 0)
		computeEncoder.setBytes(&Du,   length: MemoryLayout<Float>.size, index: 1)
		computeEncoder.setBytes(&Dv,   length: MemoryLayout<Float>.size, index: 2)
		computeEncoder.setBytes(&F,    length: MemoryLayout<Float>.size, index: 3)
		computeEncoder.setBytes(&k,    length: MemoryLayout<Float>.size, index: 4)
		
		computeEncoder.setBuffer(uBuffer,     offset: 0, index: 5)
		computeEncoder.setBuffer(uNextBuffer, offset: 0, index: 6)
		computeEncoder.setBuffer(vBuffer,     offset: 0, index: 7)
		computeEncoder.setBuffer(vNextBuffer, offset: 0, index: 8)
		
		computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
		
		computeEncoder.endEncoding()
		
		commandBuffer.commit()
		commandBuffer.waitUntilCompleted()
	}
	
	func blit() {
		let commandBuffer = commandQueue.makeCommandBuffer()!
		let blitter = commandBuffer.makeBlitCommandEncoder()!
		
		blitter.copy(from: uNextBuffer, sourceOffset: 0, to: uBuffer, destinationOffset: 0, size: cellCount * MemoryLayout<Float>.size)
		blitter.copy(from: vNextBuffer, sourceOffset: 0, to: vBuffer, destinationOffset: 0, size: cellCount * MemoryLayout<Float>.size)
		
		blitter.endEncoding()
		
		commandBuffer.commit()
		commandBuffer.waitUntilCompleted()
	}
	
	func render() {
		if
			let currentDrawable = metalKitView.currentDrawable,
			let renderPassDescriptor = metalKitView.currentRenderPassDescriptor {
			
			if interpolate < 1 {
				interpolate += 0.025
			}
			
			renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
			
			let commandBuffer = commandQueue.makeCommandBuffer()!
			let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
			
			renderEncoder.pushDebugGroup("Bug Group Alpha")
			renderEncoder.label = "Plane Encoding"
			
			renderEncoder.setRenderPipelineState(pipelineState)
			renderEncoder.setDepthStencilState(depthStencilState)
			
			renderEncoder.setVertexBytes(&time, length: MemoryLayout<Float>.stride, index: 0)
			renderEncoder.setVertexBytes(&sceneConstants, length: MemoryLayout<SceneConstants>.stride, index: 1)
			renderEncoder.setVertexBytes(&planeConstants, length: MemoryLayout<ModelConstants>.stride, index: 2)
			
			renderEncoder.setVertexBuffer(meshBuffer, offset: 0, index: 3)
			renderEncoder.setVertexBuffer(uBuffer, offset: 0, index: 4)
			renderEncoder.setVertexBytes(&scheme, length: MemoryLayout<Int>.stride, index: 5)
			renderEncoder.setVertexBytes(&topology, length: MemoryLayout<Int>.stride, index: 6)
			renderEncoder.setVertexBytes(&topologyOld, length: MemoryLayout<Int>.stride, index: 7)
			renderEncoder.setVertexBytes(&interpolate, length: MemoryLayout<Float>.stride, index: 8)
			
			renderEncoder.setTriangleFillMode(fill ? .fill : .lines)
			
			renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
			
//			renderEncoder.setCullMode(.front)
			
			renderEncoder.popDebugGroup()
			renderEncoder.endEncoding()
			
			commandBuffer.present(currentDrawable)
			commandBuffer.commit()
		}
	}
	
	func reshape() { }
	
	public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		reshape()
	}

}

func s(_ n: Int) -> String {
	if 99 < n { return "\(n)" }
	if 9 < n { return "0\(n)" }
	return "00\(n)"
}

func readableNumber(_ n: Int) -> String {
	if n < 1000 { return "\(n)" }
	return readableNumber(n / 1000) + ",\(s(n % 1000))"
}

public func timer(_ name: String, _ ƒ: ()-> Void) {
	let t0 = CFAbsoluteTimeGetCurrent()
	ƒ()
	let t1 = CFAbsoluteTimeGetCurrent()
	print("⏱ time to execute \(name): \(t1-t0) seconds")
}
