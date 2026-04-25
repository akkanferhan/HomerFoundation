import Foundation

/// A `#`-driven phone-number mask, e.g. `"+## (###) ###-####"`. Use
/// ``PhoneNumberFormat/init(mask:)`` for arbitrary masks or one of the named
/// presets.
public struct PhoneNumberFormat: Sendable, Equatable {
    /// The literal mask with `#` placeholders for digits.
    public let mask: String

    public init(mask: String) {
        self.mask = mask
    }

    /// `+## (###) ###-####` — 12 digits with country prefix slot.
    public static let international = PhoneNumberFormat(mask: "+## (###) ###-####")
    /// `(###) ### ## ##` — 10-digit national style.
    public static let national = PhoneNumberFormat(mask: "(###) ### ## ##")
    /// `### ##### ##` — compact 10-digit style.
    public static let compact = PhoneNumberFormat(mask: "### ##### ##")
}

/// Applies a ``PhoneNumberFormat`` to a free-form string of digits, stripping
/// non-digit characters and (optionally) a leading `0`.
public struct PhoneNumberFormatter: Sendable {
    /// The mask to apply.
    public let format: PhoneNumberFormat
    /// When `true`, a single leading `0` is dropped before formatting (the
    /// common Turkish trunk-prefix normalisation).
    public let stripsLeadingZero: Bool

    public init(format: PhoneNumberFormat, stripsLeadingZero: Bool = true) {
        self.format = format
        self.stripsLeadingZero = stripsLeadingZero
    }

    /// Formats `input` against the mask. Non-digit characters are stripped, the
    /// leading `0` is optionally removed, and excess digits beyond the mask's
    /// `#` count are truncated. Empty input returns `""`.
    public func format(_ input: String) -> String {
        var digits = input.filter(\.isNumber)
        guard digits.isNotEmpty else { return "" }

        if stripsLeadingZero, digits.count > 1, digits.first == "0" {
            digits.removeFirst()
        }

        let mask = format.mask
        let maxDigits = mask.reduce(0) { $1 == "#" ? $0 + 1 : $0 }
        let limited = digits.prefix(maxDigits)

        var result = ""
        var maskIterator = mask.makeIterator()
        for digit in limited {
            while let next = maskIterator.next() {
                if next == "#" { break }
                result.append(next)
            }
            result.append(digit)
        }
        return result
    }
}
