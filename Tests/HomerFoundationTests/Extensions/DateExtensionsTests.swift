import Foundation
import Testing
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

    @Test("isInPast and isInFuture are mutually exclusive against now")
    func pastFuture() {
        let past = Date(timeIntervalSinceNow: -60)
        let future = Date(timeIntervalSinceNow: 60)
        #expect(past.isInPast)
        #expect(!past.isInFuture)
        #expect(future.isInFuture)
        #expect(!future.isInPast)
    }

    @Test("startOfDay returns midnight in the supplied calendar")
    func startOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let utc = TimeZone(identifier: "UTC")!
        let posix = Locale(identifier: "en_US_POSIX")
        let date = Date(timeIntervalSince1970: 1_700_000_000) // 2023-11-14 22:13:20 UTC
        let midnight = date.startOfDay(in: calendar)
        #expect(midnight.string(withFormat: "yyyy-MM-dd HH:mm:ss", locale: posix, timeZone: utc) == "2023-11-14 00:00:00")
    }

    @Test("isSameDay collapses different times within one calendar day")
    func sameDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let morning = Date(timeIntervalSince1970: 1_700_000_000)         // 2023-11-14 22:13:20
        let stillSameDay = morning.addingTimeInterval(-60 * 60)          // 2023-11-14 21:13:20
        let nextDay = morning.addingTimeInterval(60 * 60 * 24)
        #expect(morning.isSameDay(as: stillSameDay, in: calendar))
        #expect(!morning.isSameDay(as: nextDay, in: calendar))
    }

    @Test("isToday / isYesterday / isTomorrow classify day offsets from now")
    func dayClassification() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = now.addingTimeInterval(-86_400)
        let tomorrow = now.addingTimeInterval(86_400)

        #expect(now.isToday(in: calendar))
        #expect(!now.isYesterday(in: calendar))
        #expect(!now.isTomorrow(in: calendar))
        #expect(yesterday.isYesterday(in: calendar))
        #expect(tomorrow.isTomorrow(in: calendar))
    }

    @Test("adding(_:_:) shifts by calendar components, including negatives")
    func calendarAdding() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let base = Date(timeIntervalSince1970: 1_700_000_000) // 2023-11-14 22:13:20 UTC

        let nextDay = try #require(base.adding(1, .day, in: calendar))
        #expect(nextDay.timeIntervalSince(base) == 86_400)

        let previousMonth = try #require(base.adding(-1, .month, in: calendar))
        #expect(previousMonth.string(withFormat: "yyyy-MM-dd", locale: Locale(identifier: "en_US_POSIX"), timeZone: calendar.timeZone) == "2023-10-14")
    }

    @Test("adding(_:_:) respects month-length clamping")
    func calendarAddingClampsMonthEnd() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let jan31 = try #require("2024-01-31".asDate(format: "yyyy-MM-dd", locale: Locale(identifier: "en_US_POSIX"), timeZone: calendar.timeZone))
        let shifted = try #require(jan31.adding(1, .month, in: calendar))
        #expect(shifted.string(withFormat: "yyyy-MM-dd", locale: Locale(identifier: "en_US_POSIX"), timeZone: calendar.timeZone) == "2024-02-29")
    }
}
