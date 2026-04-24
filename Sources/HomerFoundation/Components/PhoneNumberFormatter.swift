import Foundation

public struct PhoneNumberFormat: Sendable, Equatable {
    public let mask: String

    public init(mask: String) {
        self.mask = mask
    }

    public static let international = PhoneNumberFormat(mask: "+## (###) ###-####")
    public static let national = PhoneNumberFormat(mask: "(###) ### ## ##")
    public static let compact = PhoneNumberFormat(mask: "### ##### ##")
}

public struct PhoneNumberFormatter: Sendable {
    public let format: PhoneNumberFormat
    public let stripsLeadingZero: Bool

    public init(format: PhoneNumberFormat, stripsLeadingZero: Bool = true) {
        self.format = format
        self.stripsLeadingZero = stripsLeadingZero
    }

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
