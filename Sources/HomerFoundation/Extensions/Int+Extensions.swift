import CoreGraphics
import Foundation

public extension Int {
    var asCGFloat: CGFloat { CGFloat(self) }
    var asFloat: Float { Float(self) }
    var asDouble: Double { Double(self) }
    var asString: String { String(self) }
}
