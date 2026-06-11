import Foundation

public extension TimeInterval {
    /// Identity factory, provided for call-site symmetry with the other
    /// unit factories — `.seconds(90)` reads better than a bare `90`
    /// next to `.minutes(5)`.
    static func seconds(_ value: Double) -> TimeInterval {
        value
    }

    /// `value` minutes expressed in seconds.
    static func minutes(_ value: Double) -> TimeInterval {
        value * 60
    }

    /// `value` hours expressed in seconds.
    static func hours(_ value: Double) -> TimeInterval {
        value * 3_600
    }

    /// `value` days (of exactly 24 hours) expressed in seconds. Calendar
    /// effects such as DST transitions are deliberately ignored — use
    /// `Calendar.date(byAdding:)` (or ``Foundation/Date/adding(_:_:in:)``)
    /// for wall-clock arithmetic.
    static func days(_ value: Double) -> TimeInterval {
        value * 86_400
    }
}
