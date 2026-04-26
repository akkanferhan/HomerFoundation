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

    @Test("zeroOmitted drops fraction when whole and respects decimals otherwise")
    func zeroOmitted() {
        #expect((3.0).zeroOmitted() == "3")
        #expect((3.5).zeroOmitted() == "3.5")
        #expect((3.14159).zeroOmitted(decimals: 2) == "3.14")
        #expect((3.14159).zeroOmitted(decimals: 0) == "3")
        #expect((-2.5).zeroOmitted() == "-2.5")
        #expect((1.5).zeroOmitted(decimals: -3) == "2")
    }
}
