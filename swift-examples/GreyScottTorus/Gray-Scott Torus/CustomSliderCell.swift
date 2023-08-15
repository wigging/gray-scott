import Cocoa

class CustomSliderCell: NSSliderCell {
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func drawBar(inside aRect: NSRect, flipped: Bool) {
		var rect = aRect
		rect.size.height = CGFloat(5)
		let barRadius = CGFloat(2.5)
		let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
		let finalWidth = CGFloat(value * (self.controlView!.frame.size.width - 8))
		var leftRect = rect
		leftRect.size.width = finalWidth
		let bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
		NSColor.darkGray.setFill()
		bg.fill()
		let active = NSBezierPath(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
		NSColor.lightGray.setFill()
		active.fill()
	}
}
