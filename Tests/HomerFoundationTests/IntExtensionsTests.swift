import Testing
import CoreGraphics
@testable import HomerFoundation

@Suite("Int+Extensions")
struct IntExtensionsTests {
    @Test("Numeric coercions return matching values")
    func coercions() {
        let value = 7
        #expect(value.asCGFloat == CGFloat(7))
        #expect(value.asFloat == Float(7))
        #expect(value.asDouble == Double(7))
        #expect(value.asString == "7")
    }

    @Test("Negative and zero coercions are correct")
    func edges() {
        #expect((-1).asDouble == -1.0)
        #expect(0.asString == "0")
        #expect(0.asCGFloat == CGFloat(0))
    }
}
