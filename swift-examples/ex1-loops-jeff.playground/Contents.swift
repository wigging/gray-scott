//: ## Ex 1. Gray-Scott Modeling
var W = Lattice2d.zero

time("Generating Model", precision: .seconds) {
	W = generate()
}

MPL.plot(W, title: "Swift", interpolation: "bicubic")
