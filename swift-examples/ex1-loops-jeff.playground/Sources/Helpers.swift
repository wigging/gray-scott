import Foundation

public func * (left: Int, right: Range<Int>) -> [Int] {
	right.map { $0 * left }
}

public func repeating(count: Int, _ block: () -> Void) {
	for _ in 1...count { block() }
}

public func time(_ label: String, precision: TimePrecision = .microSeconds, ƒ: () -> Void) {
	print("start [\(label)] ⏱")
	let t0 = CFAbsoluteTimeGetCurrent()
	ƒ()
	let t1 = CFAbsoluteTimeGetCurrent()
	
	let Δt = round(1_000_000 * (t1 - t0)) / precision.rawValue
	
	print("⏱ \(label): \(Δt) \(precision.description)")
}

public enum TimePrecision: CFTimeInterval {
	case microSeconds = 1
	case milliSeconds = 1_000
	case seconds = 1_000_000
	
	var description: String {
		switch self {
			case .microSeconds: return "μs"
			case .milliSeconds: return "ms"
			case .seconds: return "seconds"
		}
	}
}
