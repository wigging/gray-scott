import Foundation

public let plt = Python.import("matplotlib.pyplot")
public let pylab = Python.import("pylab")
public let pydatetime = Python.import("datetime")
public typealias MPL = Matplotlib

public enum Matplotlib {
	
	public enum MPLColor: String {
		case blue, green, red, cyan, magenta, yellow, black = "k", white
	}
	
	public enum MPLLine: String {
		case none = ""
		case solid = "-"
		case dashed = "--"
		case dashDot = "-."
		case dotted = ":"
	}
	
	public enum MPLMarker: String {
		case none = ""
		case point = "."
		case pixel = ","
		case circle = "o"
		case triangleDown = "v"
		case triangleUp = "^"
		case triangleLeft = "<"
		case triangleRight = ">"
		case triDown = "1"
		case triUp = "2"
		case triLeft = "3"
		case triRight = "4"
		case square = "s"
		case pentagon = "p"
		case hexagon1 = "h"
		case hexagon2 = "H"
		case octogon = "8"
		case star = "*"
		case plus = "+"
		case plusFilled = "P"
		case x = "x"
		case xFilled = "X"
		case diamond = "D"
		case diamondThin = "d"
		case vertical = "|"
		case horizontal = "_"
	}
	
	public static func lineStyle(line: MPLLine, marker: MPLMarker = .none) -> String {
		"\(line.rawValue)\(marker.rawValue)"
	}
	
	public static func lineStyle(line: MPLLine, marker: MPLMarker = .none, color: MPLColor) -> String {
		"\(color.rawValue.first!)\(line.rawValue)\(marker.rawValue)"
	}
	
	public static func plot(xs: [[Double]], ys: [[Double]], title: String = "", xAxisTitle: String = "", yAxisTitle: String = "", lineStyles: [String] = [], legend: [String] = []) {
		
		if ys.isEmpty || xs.isEmpty { return }
		if xs.count != ys.count { return }
		
		for index in 0..<xs.count {
			if xs[index].count != ys[index].count { return }
		}
		
		plt.title(title)
		plt.xlabel(xAxisTitle)
		plt.ylabel(yAxisTitle)
		
		for index in 0..<xs.count {
			if index < lineStyles.count {
				plt.plot(xs[index], ys[index], lineStyles[index])
			}
			else {
				plt.plot(xs[index], ys[index])
			}
		}
		
		if !legend.isEmpty {
			plt.gca().legend(legend)
		}
		
		plt.margins(0.1)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			plt.show()
		}
	}
	
	public static func plot(x: [Double], ys: [[Double]], title: String = "", xAxisTitle: String = "", yAxisTitle: String = "", lineStyles: [String] = [], legend: [String] = []) {
		
		if ys.isEmpty || x.isEmpty { return }
		
		for index in 0..<ys.count {
			if x.count != ys[index].count { return }
		}
		
		plt.title(title)
		plt.xlabel(xAxisTitle)
		plt.ylabel(yAxisTitle)
		
		for index in 0..<ys.count {
			if index < lineStyles.count {
				plt.plot(x, ys[index], lineStyles[index])
			}
			else {
				plt.plot(x, ys[index])
			}
		}
		
		if !legend.isEmpty {
			plt.gca().legend(legend)
		}
		
		plt.margins(0.1)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			plt.show()
		}
	}
	
	public static func plot(x: [Double], y: [Double], title: String = "", xAxisTitle: String = "", yAxisTitle: String = "", lineStyles: [String] = [], legend: [String] = []) {
		plot(xs: [x], ys: [y], title: title, xAxisTitle: xAxisTitle, yAxisTitle: yAxisTitle, lineStyles: lineStyles)
	}
	
	public static func plot(x: [Int], y: [Double], title: String = "", xAxisTitle: String = "", yAxisTitle: String = "", lineStyles: [String] = [], legend: [String] = []) {
		let xx = x.map { Double($0) }
		
		plot(xs: [xx], ys: [y], title: title, xAxisTitle: xAxisTitle, yAxisTitle: yAxisTitle, lineStyles: lineStyles)
	}
	
}
