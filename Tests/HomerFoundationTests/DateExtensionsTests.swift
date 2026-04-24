import Testing
import Foundation
@testable import HomerFoundation

@Suite("Date+Extensions")
struct DateExtensionsTests {
    @Test("millisecondsSince1970 multiplies the seconds value by 1000")
    func milliseconds() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        #expect(date.millisecondsSince1970 == 1_700_000_000_000)
    }

    @Test("string(withFormat:) renders with the given locale and time zone")
    func stringWithFormat() {
        let date = Date(timeIntervalSince1970: 0)
        let utc = TimeZone(identifier: "UTC")!
        let posix = Locale(identifier: "en_US_POSIX")
        #expect(date.string(withFormat: "yyyy-MM-dd", locale: posix, timeZone: utc) == "1970-01-01")
        #expect(date.string(withFormat: "HH:mm:ss", locale: posix, timeZone: utc) == "00:00:00")
    }

}
