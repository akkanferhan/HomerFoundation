import Foundation

public extension Date {
    /// Unix epoch in milliseconds — `timeIntervalSince1970 * 1000`.
    var millisecondsSince1970: Double {
        timeIntervalSince1970 * 1000
    }
    
    /// `true` when `self` is strictly before `Date()` (now). Equal-to-now is `false`.
    var isInPast: Bool { self < Date() }

    /// `true` when `self` is strictly after `Date()` (now). Equal-to-now is `false`.
    var isInFuture: Bool { self > Date() }

    /// Renders the date with a custom `DateFormatter` pattern.
    /// - Parameters:
    ///   - format: A `DateFormatter`-compatible pattern.
    ///   - locale: Output locale. Use `en_US_POSIX` for fixed-format strings.
    ///   - timeZone: The zone to render the wall-clock in.
    /// - Note: Allocates a fresh `DateFormatter` on every call. For tight loops,
    ///   reuse a formatter directly.
    func string(withFormat format: String, locale: Locale = .current, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.timeZone = timeZone
        return formatter.string(from: self)
    }

    /// Midnight at the start of the calendar day containing `self`.
    /// - Parameter calendar: The calendar used to find the day boundary. Defaults
    ///   to `.current`. Pass an explicit calendar for tests or fixed scheduling.
    func startOfDay(in calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }

    /// `true` when `self` falls on the same calendar day as `other`.
    /// - Parameters:
    ///   - other: The date to compare against.
    ///   - calendar: The calendar used to determine day boundaries.
    func isSameDay(as other: Date, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }

    /// `true` when `self` falls on the current calendar day.
    /// - Parameter calendar: The calendar used to determine day boundaries.
    func isToday(in calendar: Calendar = .current) -> Bool {
        calendar.isDateInToday(self)
    }

    /// `true` when `self` falls on the calendar day before today.
    /// - Parameter calendar: The calendar used to determine day boundaries.
    func isYesterday(in calendar: Calendar = .current) -> Bool {
        calendar.isDateInYesterday(self)
    }

    /// `true` when `self` falls on the calendar day after today.
    /// - Parameter calendar: The calendar used to determine day boundaries.
    func isTomorrow(in calendar: Calendar = .current) -> Bool {
        calendar.isDateInTomorrow(self)
    }

    /// Calendar-aware arithmetic — `date.adding(3, .day)`,
    /// `date.adding(-1, .month)`. Unlike adding a raw `TimeInterval`,
    /// this respects DST transitions, month lengths, and leap years.
    /// - Parameters:
    ///   - value: How many `component` units to add; negative subtracts.
    ///   - component: The calendar unit to add (`.day`, `.month`, …).
    ///   - calendar: The calendar performing the arithmetic.
    /// - Returns: The shifted date, or `nil` when the calendar cannot
    ///   represent the result.
    func adding(_ value: Int, _ component: Calendar.Component, in calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: component, value: value, to: self)
    }
}
