import Foundation

public extension String {
    /// Whitespace and newline characters trimmed from both ends.
    var whitespaceTrimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// All whitespace and newline characters removed (anywhere in the string).
    var removingWhitespaces: String {
        components(separatedBy: .whitespacesAndNewlines).joined()
    }

    /// Only the ASCII digits `0`–`9`, in their original order; everything
    /// else (separators, letters, `+`, non-ASCII numerals) is dropped.
    /// The usual pre-clean for phone numbers, OTP codes, and card numbers
    /// — pairs with ``PhoneNumberFormatter``.
    var digitsOnly: String {
        filter { $0.isASCII && $0.isNumber }
    }

    /// Returns `nil` when the string is empty, otherwise returns `self`.
    /// Pairs with `??` to fall back to a default — `name.nilIfEmpty ?? "Anonymous"`.
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }

    /// Returns `nil` when the string is empty after trimming whitespace and
    /// newlines from both ends, otherwise returns the trimmed value. Useful for
    /// validating user-entered text fields where pure-whitespace input should
    /// be treated as missing.
    var trimmedOrNil: String? {
        let trimmed = whitespaceTrimmed
        return trimmed.isEmpty ? nil : trimmed
    }

    /// `true` when the entire string matches a basic email regex. Anchored to
    /// the whole string, so substrings inside larger text do not match.
    var isValidEmail: Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return range(of: pattern, options: .regularExpression) != nil
    }

    /// `true` when the string is a strict E.164 phone number: a leading
    /// `+`, a non-zero first digit, and 8–15 digits total. Formatting
    /// characters are **not** tolerated — normalise user input first
    /// (e.g. `"+" + raw.digitsOnly`) or use ``PhoneNumberFormatter``
    /// for display masks. Anchored to the whole string.
    var isValidE164PhoneNumber: Bool {
        let pattern = "^\\+[1-9]\\d{7,14}$"
        return range(of: pattern, options: .regularExpression) != nil
    }

    /// Words split on any whitespace (spaces, tabs, newlines). Consecutive
    /// whitespace runs collapse to a single separator. Use ``wordCount`` for
    /// the count.
    var parsedWords: [Substring] { split(whereSeparator: \.isWhitespace) }

    /// Number of whitespace-separated words. Empty strings return `0`.
    var wordCount: Int { parsedWords.count }

    /// ASCII transliteration of Turkish-specific characters (ç→c, ş→s, …).
    var withTurkishTransliteration: String {
        let mapping: [Character: Character] = [
            "ç": "c", "ö": "o", "ı": "i", "ğ": "g", "ü": "u", "ş": "s",
            "Ç": "C", "Ö": "O", "İ": "I", "Ğ": "G", "Ü": "U", "Ş": "S"
        ]
        return String(map { mapping[$0] ?? $0 })
    }

    /// Parses the string as a `Double` via `Double.init(_:)`. Returns `nil`
    /// when the string is not a valid decimal literal.
    var asDouble: Double? { Double(self) }

    /// Builds a `URL` via `URL(string:)`. Returns `nil` for strings that are
    /// not valid URLs (e.g. empty, contain disallowed characters).
    var asURL: URL? { URL(string: self) }

    /// Parses an ISO-8601 timestamp, with or without fractional seconds.
    /// Returns `nil` when the string is not a recognised ISO-8601 form.
    var asISO8601Date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: self) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: self)
    }

    /// Parses with a custom `DateFormatter` format string.
    /// - Parameters:
    ///   - format: A `DateFormatter`-compatible pattern (e.g. `"yyyy-MM-dd"`).
    ///   - locale: Locale for parsing. Use `en_US_POSIX` for fixed-format strings.
    ///   - timeZone: Time zone the input is expressed in.
    func asDate(format: String, locale: Locale = .current, timeZone: TimeZone = .current) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.timeZone = timeZone
        return formatter.date(from: self)
    }
}

/// Integer-based subscripts on `String`. Indexing is `O(n)` for non-ASCII
/// strings; out-of-range indices trap (matching `Array` behaviour).
///
/// - Important: These subscripts trap on out-of-range indices. For safe
///   element access prefer ``Swift/Collection/subscript(safe:)`` after first
///   converting to `Array(self)`.
public extension String {
    /// The character at the integer offset from `startIndex`. Traps when
    /// `integer` is out of bounds.
    subscript(integer: Int) -> Character {
        self[index(startIndex, offsetBy: integer)]
    }

    /// Substring delimited by integer half-open bounds. Traps on out-of-range bounds.
    subscript(bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start..<end]
    }

    /// Substring delimited by integer closed bounds. Traps on out-of-range bounds.
    subscript(bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start...end]
    }

    /// Substring from `lowerBound` to the end of the string.
    subscript(bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        return self[start...]
    }

    /// Substring from `startIndex` through `upperBound` (inclusive).
    subscript(bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[...end]
    }

    /// Substring from `startIndex` up to (but not including) `upperBound`.
    subscript(bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[..<end]
    }
}

/// Mirrored integer subscripts on `Substring`. Same trap behaviour as the
/// `String` overloads.
public extension Substring {
    /// The character at the integer offset from `startIndex`. Traps when
    /// `integer` is out of bounds.
    subscript(integer: Int) -> Character {
        self[index(startIndex, offsetBy: integer)]
    }

    /// Substring delimited by integer half-open bounds. Traps on out-of-range bounds.
    subscript(bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start..<end]
    }

    /// Substring delimited by integer closed bounds. Traps on out-of-range bounds.
    subscript(bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start...end]
    }

    /// Substring from `lowerBound` to the end of the substring.
    subscript(bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        return self[start...]
    }

    /// Substring from `startIndex` through `upperBound` (inclusive).
    subscript(bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[...end]
    }

    /// Substring from `startIndex` up to (but not including) `upperBound`.
    subscript(bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[..<end]
    }
}
