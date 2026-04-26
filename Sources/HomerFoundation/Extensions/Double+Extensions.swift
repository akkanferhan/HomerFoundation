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

    /// Renders the value with up to `decimals` fractional digits, dropping the
    /// fraction entirely when the value is a whole number. Uses fixed-format
    /// `String(format:)` under the hood, so the output is locale-independent
    /// (decimal separator is always `.`).
    /// - Parameter decimals: Maximum fractional digits when the value is not
    ///   whole. Defaults to `1`. Negative values are treated as `0`.
    func zeroOmitted(decimals: Int = 1) -> String {
        if truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", self)
        }
        let clamped = max(0, decimals)
        return String(format: "%.\(clamped)f", self)
    }
}
