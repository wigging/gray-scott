import Accelerate

postfix operator %
infix operator +! : AdditionPrecedence

public extension Double {
	static postfix func % (left: Double) -> Percentage {
		Percentage(value: left)
	}
}

public extension Array where Element == Double {
	static func * (left: Double, right: Array) -> Array {
		var out = right
		cblas_dscal(Int32(out.count), left, &out, 1)
		
		return out
	}
	
	static func +! (left: Array, right: Array) -> Array {
		var out = right
		cblas_daxpy(Int32(out.count), 1, left, 1, &out, 1)
		
		return out
	}
	
}

public struct Percentage {
	var value: Double
}

public func * (left: Int, right: Percentage) -> Double {
	Double(left) * right
}

public func * (left: Double, right: Percentage) -> Double {
	left * right.value / 100
}
