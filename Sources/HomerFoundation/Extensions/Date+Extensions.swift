import Foundation

public extension Date {
    /// Unix epoch in milliseconds — `timeIntervalSince1970 * 1000`.
    var millisecondsSince1970: Double {
        timeIntervalSince1970 * 1000
    }

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

    /// `true` when `self` is strictly before `Date()` (now). Equal-to-now is `false`.
    var isInPast: Bool { self < Date() }

    /// `true` when `self` is strictly after `Date()` (now). Equal-to-now is `false`.
    var isInFuture: Bool { self > Date() }

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
}
