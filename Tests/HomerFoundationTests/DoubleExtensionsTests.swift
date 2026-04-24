import Testing
import CoreGraphics
@testable import HomerFoundation

@Suite("Double+Extensions")
struct DoubleExtensionsTests {
    @Test("Numeric coercions return matching values")
    func coercions() {
        let value: Double = 3.75
        #expect(value.asCGFloat == CGFloat(3.75))
        #expect(value.asFloat == Float(3.75))
        #expect(value.asInt == 3)
        #expect(value.asString == "3.75")
    }

    @Test("rounded(toPlaces:) rounds to the requested decimal precision")
    func rounded() {
        #expect((1.234).rounded(toPlaces: 2) == 1.23)
        #expect((1.236).rounded(toPlaces: 2) == 1.24)
        #expect((1.0).rounded(toPlaces: 3) == 1.0)
        #expect((1.999).rounded(toPlaces: 0) == 2.0)
    }
}
