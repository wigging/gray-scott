import Accelerate

public typealias Lattice2dSpan = (xRange: ClosedRange<Int>, yRange: ClosedRange<Int>)
public typealias Shape2d = (rows: Int, columns: Int)

/// Lattices represent patches of n-dimensional manifolds with values stored at regular intervals. They are not meant to be used like Matrices, but are ideal playgrounds for evolving systems and simulations that need to evaluate their values in parallel.
public struct Lattice2d: CustomDebugStringConvertible {
	public var span: Lattice2dSpan
	public var values: [Double]
	private var valueCount: Int = 0
	
	// MARK: - Descriptions -
	
	public var debugDescription: String {
		var out = ""
		let width = span.xRange.count
		
		for row in span.yRange {
			let p = row * width
			out += values[p ..< p + width]
				.map { String(format: "%10.4f \t", $0) }
				.reduce("", +) + "\n"
		}
		
		return out
	}
	
	// MARK: - Premade Lattices -
	
	static public var zero: Lattice2d {
		Lattice2d(span: (0...0, 0...0))
	}
	
	// MARK: - Init options -
	
	public init?(values valuesIn: [[Double]]) {
		if valuesIn.isEmpty { return nil }
		
		let referenceLength = valuesIn.first!.count
		
		for index in 1 ..< valuesIn.count {
			if valuesIn[index].count != referenceLength {
				return nil
			}
		}
		
		span = (0...(referenceLength - 1), 0...(valuesIn.count - 1))
		values = valuesIn.flatMap { $0 }
		valueCount = valuesIn.count
	}
	
	public init(span spanIn: Lattice2dSpan) {
		span = spanIn
		valueCount = spanIn.xRange.count * spanIn.yRange.count
		values = [Double](repeating: .nan, count: valueCount)
	}
	
	public init(span spanIn: Lattice2dSpan, withBaseValue valueIn: Double) {
		span = spanIn
		valueCount = spanIn.xRange.count * spanIn.yRange.count
		values = [Double](repeating: valueIn, count: valueCount)
	}
	
	public init?(span spanIn: Lattice2dSpan, values valuesIn: [Double]) {
		if spanIn.xRange.count * spanIn.yRange.count != valuesIn.count {
			return nil
		}
		
		span = spanIn
		values = valuesIn
		valueCount = values.count
	}
	
	public init(shape shapeIn: Shape2d) {
		span = (0...(shapeIn.rows - 1), 0...(shapeIn.columns - 1))
		valueCount = shapeIn.0 * shapeIn.1
		values = [Double](repeating: .nan, count: valueCount)
	}
	
	public init(shape shapeIn: Shape2d, withBaseValue valueIn: Double) {
		self.init(span: (0...(shapeIn.rows - 1), 0...(shapeIn.columns - 1)), withBaseValue: valueIn)
	}
	
	public init?(shape shapeIn: Shape2d, values valuesIn: [Double]) {
		self.init(span: (0...(shapeIn.rows - 1), 0...(shapeIn.columns - 1)), values: valuesIn)
	}
	
	public init(shape shapeIn: Shape2d, usingGenerator function: () -> Double) {
		span = (0...(shapeIn.rows - 1), 0...(shapeIn.columns - 1))
		valueCount = shapeIn.0 * shapeIn.1
		values = (0..<(shapeIn.rows * shapeIn.columns)).map { _ in function() }
	}
	
	// MARK: - Sublattices -
	
	public subscript(x: Int, y: Int) -> Any {
		get {
			values[(y * span.xRange.count) + x]
		}
		set(newValue) {
			if let valueIn = newValue as? Double {
				values[(y * span.xRange.count) + x] = valueIn
			}
			else if let valuesIn = newValue as? [Double] {
				let base = (y * span.xRange.count) + x
				for (index, offset) in (base ..< base + valuesIn.count).enumerated() {
					values[offset] = valuesIn[index]
				}
			}
			else if let matrix = newValue as? Lattice2d {
				let base = (y * span.xRange.count) + x
				let s = matrix.span
				
				let m = vDSP_Length(s.xRange.count)
				let n = vDSP_Length(s.yRange.count)
				let ta = vDSP_Length(s.xRange.count)
				let tc = vDSP_Length(span.xRange.count)
				
				vDSP_mmovD(matrix.values, &values[base], m, n, ta, tc)
			}
			else {
				print("nope. hint: type = \(type(of: newValue))")
			}
		}
	}
	
	// experimental and DOESN'T WORK: (stopping work on it for now)
	public subscript(rows: Range<Int>, columns: Range<Int>) -> Lattice2d {
		let rs = rows.distance(from: rows.lowerBound, to: rows.upperBound)
		let cs = columns.distance(from: columns.lowerBound, to: columns.upperBound)
		
		var newValues = [Double](repeating: .nan, count: rs * cs)
		
		let m = vDSP_Length(cs)
		let n = vDSP_Length(rs)
		let ta = vDSP_Length(span.xRange.count)
		let tc = vDSP_Length(cs)
		
		let low = rows.lowerBound * span.xRange.count + columns.lowerBound
		let high = low + rs * cs
		
		let referenceValues = Array(values[low..<high])
		
		vDSP_mmovD(referenceValues, &newValues[0], m, n, ta, tc)
		
		return Lattice2d(shape: (rs, cs), values: newValues)!
	}
	
	// MARK: - Generating methods -
	// FIXME: Handle differing span cases
	
	static public func * (left: Double, right: Lattice2d) -> Lattice2d {
		let count = right.span.xRange.count * right.span.yRange.count
		var out = right.values
		
		cblas_dscal(Int32(count), left, &out, 1)
		
		return Lattice2d(span: right.span, values: out)!
	}
	
	static public func * (left: Lattice2d, right: Lattice2d) -> Lattice2d {
		if left.span == right.span {
			let out = vDSP.multiply(left.values, right.values)
			
			return Lattice2d(span: left.span, values: out)!
		}
		// if left is bigger than right {
		//      zero out an output lattice
		//      use indexing to take a slice the size of right
		//      ⨀ the smaller matrix
		//      add to the output lattice
		// }
		// if left is smaller than right {}
		// if l.w <= r.w && r.h < l.h    {}
		// if r.w <= l.w && l.h < r.h    {}
		
		let out = vDSP.multiply(left.values, right.values)
		
		return Lattice2d(span: left.span, values: out)!
	}
	
	static public func - (left: Lattice2d, right: Lattice2d) -> Lattice2d {
		let a = right.values
		var b = left.values
		
		cblas_daxpy(Int32(right.valueCount), -1, a, 1, &b, 1)
		
		return Lattice2d(span: left.span, values: b)!
	}
	
	static public func + (left: Lattice2d, right: Lattice2d) -> Lattice2d {
		let a = left.values
		var b = right.values
		
		cblas_daxpy(Int32(left.valueCount), 1, a, 1, &b, 1)
		
		return Lattice2d(span: left.span, values: b)!
	}
	
	static public func laplacian5point(_ M: Lattice2d) -> Lattice2d {
		let v = M.values
		let vc = v.count
		let c = M.span.xRange.count
		
		let up    = v[c...] + v[..<c]
		let down  = v[(vc - c)...] + v[..<(vc - c)]
		let left  = v[1...] + [v.first!]
		let right = [v.last!] + v[..<(vc-1)]
		
		let fxy = -4 * v +! Array(left) +! Array(right) +! Array(down) +! Array(up)
		
		return Lattice2d(span: M.span, values: fxy)!
	}
	
	// MARK: - Derived operations -

	static public prefix func - (right: Lattice2d) -> Lattice2d {
		-1 * right
	}
	
	static public func += (left: inout Lattice2d, right: Lattice2d) {
		left = left + right
	}
	
	static public func * (left: Lattice2d, right: Double) -> Lattice2d {
		right * left
	}
	
	static public func + (left: Lattice2d, right: Double) -> Lattice2d {
		right + left
	}
	
	static public func - (left: Double, right: Lattice2d) -> Lattice2d {
		left + (-1 * right)
	}
	
	static public func + (left: Double, right: Lattice2d) -> Lattice2d {
		Lattice2d(span: right.span, withBaseValue: left) + right
	}
	
}

// MARK: - Extensions -

extension Matplotlib {
	public static func plot(_ lattice: Lattice2d, title: String = "", interpolation: String = "") {
		pylab.title(title)
		pylab.margins(0.1)

		let values = lattice.values
		let i = lattice.span.yRange.count
		let range = i * (0..<(values.count / i))
		let data = range.map { Array(values[$0 ... ($0 + i - 1)]) }

		pylab.imshow(data, origin: "lower", extent: [0, i, 0, lattice.span.xRange.count + 1], interpolation: interpolation.isEmpty ? "bicubic" : interpolation, cmap: plt.cm.jet)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			plt.show()
		}
	}

}
