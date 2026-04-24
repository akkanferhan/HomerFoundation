import Foundation

public extension String {
    var whitespaceTrimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var removingWhitespaces: String {
        components(separatedBy: .whitespacesAndNewlines).joined()
    }

    var isValidEmail: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return range(of: pattern, options: .regularExpression) != nil
    }

    var parsedWords: [Substring] { split(separator: " ") }

    var wordCount: Int { isEmpty ? 0 : parsedWords.count }

    var withTurkishTransliteration: String {
        let mapping: [Character: Character] = [
            "ç": "c", "ö": "o", "ı": "i", "ğ": "g", "ü": "u", "ş": "s",
            "Ç": "C", "Ö": "O", "İ": "I", "Ğ": "G", "Ü": "U", "Ş": "S"
        ]
        return String(map { mapping[$0] ?? $0 })
    }

    var asISO8601Date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: self) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: self)
    }

    func asDate(format: String, locale: Locale = .current, timeZone: TimeZone = .current) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.timeZone = timeZone
        return formatter.date(from: self)
    }
}

public extension String {
    subscript(integer: Int) -> Character {
        self[index(startIndex, offsetBy: integer)]
    }

    subscript(bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start..<end]
    }

    subscript(bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start...end]
    }

    subscript(bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        return self[start...]
    }

    subscript(bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[...end]
    }

    subscript(bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[..<end]
    }
}

public extension Substring {
    subscript(integer: Int) -> Character {
        self[index(startIndex, offsetBy: integer)]
    }

    subscript(bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start..<end]
    }

    subscript(bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start...end]
    }

    subscript(bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        return self[start...]
    }

    subscript(bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[...end]
    }

    subscript(bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[..<end]
    }
}
