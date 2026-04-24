import CoreGraphics
import Foundation

public extension Double {
    /// `CGFloat` representation of `self`.
    var asCGFloat: CGFloat { CGFloat(self) }
    /// `Float` representation of `self` (may lose precision for large values).
    var asFloat: Float { Float(self) }
    /// `Int` representation of `self`. Traps on `NaN` or `Infinity`.
    var asInt: Int { Int(self) }
    /// `String` representation of `self`.
    var asString: String { String(self) }

    /// Rounds to the requested number of decimal places using
    /// `Double.rounded()` semantics (`.toNearestOrEven`).
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
