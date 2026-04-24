import Foundation

public extension Date {
    var millisecondsSince1970: Double {
        timeIntervalSince1970 * 1000
    }

    func string(withFormat format: String, locale: Locale = .current, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.timeZone = timeZone
        return formatter.string(from: self)
    }
}
