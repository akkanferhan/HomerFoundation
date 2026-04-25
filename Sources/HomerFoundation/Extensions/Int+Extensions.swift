import CoreGraphics
import Foundation

public extension Int {
    /// `CGFloat` representation of `self`.
    var asCGFloat: CGFloat { CGFloat(self) }
    /// `Float` representation of `self`.
    var asFloat: Float { Float(self) }
    /// `Double` representation of `self`.
    var asDouble: Double { Double(self) }
    /// `String` representation of `self`.
    var asString: String { String(self) }
}
