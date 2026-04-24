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
}
