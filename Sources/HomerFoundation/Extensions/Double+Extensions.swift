import CoreGraphics
import Foundation

public extension Double {
    var asCGFloat: CGFloat { CGFloat(self) }
    var asFloat: Float { Float(self) }
    var asInt: Int { Int(self) }
    var asString: String { String(self) }

    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
