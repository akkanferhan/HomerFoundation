import Foundation
import Testing
@testable import HomerFoundation

@Suite("TimeInterval+Extensions")
struct TimeIntervalExtensionsTests {
    @Test("unit factories convert to seconds")
    func unitFactories() {
        #expect(TimeInterval.seconds(90) == 90)
        #expect(TimeInterval.minutes(2) == 120)
        #expect(TimeInterval.hours(1.5) == 5_400)
        #expect(TimeInterval.days(2) == 172_800)
    }

    @Test("fractional and zero inputs scale linearly")
    func fractionalInputs() {
        #expect(TimeInterval.minutes(0.5) == 30)
        #expect(TimeInterval.hours(0) == 0)
        #expect(TimeInterval.days(0.25) == 21_600)
    }

    @Test("factories compose with TimeInterval-typed API call sites")
    func typeContextInference() {
        // Mirrors call sites like asyncAfter(delay: .minutes(1)).
        func takesInterval(_ interval: TimeInterval) -> TimeInterval { interval }
        #expect(takesInterval(.minutes(1)) == 60)
    }
}
