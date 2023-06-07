let lap5 = Lattice2d.laplacian5point

let n = 128

let Du = 0.2
let Dv = 0.1
let F = 0.025
let k = 0.056

let initWidth = Int(n * 15%)
var low = (n - initWidth) / 2
let initShape = Shape2d(initWidth, initWidth)
let randomSeed = { Double.random(in: 0...0.1) }
let iterations = 10_000

public func generate() -> Lattice2d {
	var U = Lattice2d(shape: (n, n), withBaseValue: 1)
	var V = Lattice2d(shape: (n, n), withBaseValue: 0)
	
	U[low, low] = 0.5  + Lattice2d(shape: initShape, usingGenerator: randomSeed)
	V[low, low] = 0.25 + Lattice2d(shape: initShape, usingGenerator: randomSeed)
	
	repeating(count: iterations) {
		let UVV = U * V * V
		
		U += Du * lap5(U) - UVV + F * (1 - U)
		V += Dv * lap5(V) + UVV - V * (F + k)
	}
	
	return U
}
