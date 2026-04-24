import Testing
@testable import HomerFoundation

@Suite("Comparable+Extensions")
struct ComparableExtensionsTests {
    @Test("clamped returns the value when inside the range")
    func insideRange() {
        #expect(5.clamped(to: 0...10) == 5)
        #expect(0.5.clamped(to: 0.0...1.0) == 0.5)
    }

    @Test("clamped returns the lower bound when below the range")
    func belowRange() {
        #expect((-3).clamped(to: 0...10) == 0)
        #expect((-0.5).clamped(to: 0.0...1.0) == 0.0)
    }

    @Test("clamped returns the upper bound when above the range")
    func aboveRange() {
        #expect(15.clamped(to: 0...10) == 10)
        #expect(1.5.clamped(to: 0.0...1.0) == 1.0)
    }

    @Test("clamped works on String comparisons")
    func stringClamping() {
        #expect("apple".clamped(to: "banana"..."pear") == "banana")
        #expect("mango".clamped(to: "banana"..."pear") == "mango")
        #expect("zebra".clamped(to: "banana"..."pear") == "pear")
    }
}
