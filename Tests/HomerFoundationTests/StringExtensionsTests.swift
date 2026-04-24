import Testing
import Foundation
@testable import HomerFoundation

@Suite("String+Extensions")
struct StringExtensionsTests {
    @Test("whitespaceTrimmed strips leading/trailing whitespace")
    func whitespaceTrimmed() {
        #expect("  hello  ".whitespaceTrimmed == "hello")
        #expect("\t a \n".whitespaceTrimmed == "a")
    }

    @Test("removingWhitespaces removes all whitespace characters")
    func removingWhitespaces() {
        #expect("a b c".removingWhitespaces == "abc")
        #expect("  hello  world  ".removingWhitespaces == "helloworld")
    }

    @Test("isValidEmail accepts well-formed and rejects malformed addresses")
    func isValidEmail() {
        #expect("foo@bar.com".isValidEmail)
        #expect("a.b+c@example.co.uk".isValidEmail)
        #expect(!"foo@".isValidEmail)
        #expect(!"foo".isValidEmail)
        #expect(!"@bar.com".isValidEmail)
    }

    @Test("isValidEmail rejects strings that merely contain a valid email substring")
    func isValidEmailRejectsSubstring() {
        #expect(!"hello foo@bar.com world".isValidEmail)
        #expect(!"foo@bar.com extra".isValidEmail)
        #expect(!"prefix foo@bar.com".isValidEmail)
        #expect(!"foo@bar.com\nbaz".isValidEmail)
    }

    @Test("parsedWords and wordCount split on spaces")
    func words() {
        #expect("hello world foo".parsedWords == ["hello", "world", "foo"])
        #expect("hello world foo".wordCount == 3)
        #expect("".wordCount == 0)
        #expect("single".wordCount == 1)
    }

    @Test("withTurkishTransliteration replaces Turkish-specific characters")
    func turkishTransliteration() {
        #expect("Çığlık".withTurkishTransliteration == "Ciglik")
        #expect("şöğüı".withTurkishTransliteration == "sogui")
        #expect("İSTANBUL".withTurkishTransliteration == "ISTANBUL")
    }

    @Test("asISO8601Date parses dates with and without fractional seconds")
    func iso8601Parse() {
        #expect("2024-01-15T10:30:00Z".asISO8601Date != nil)
        #expect("2024-01-15T10:30:00.123Z".asISO8601Date != nil)
        #expect("not a date".asISO8601Date == nil)
    }

    @Test("asDate parses with custom format and locale")
    func customDateParse() {
        let date = "2024-01-15".asDate(
            format: "yyyy-MM-dd",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: TimeZone(identifier: "UTC")!
        )
        #expect(date != nil)

        let invalid = "not-a-date".asDate(format: "yyyy-MM-dd")
        #expect(invalid == nil)
    }

    @Test("Integer subscript returns Character at index")
    func integerSubscript() {
        let s = "hello"
        #expect(s[0] == "h")
        #expect(s[4] == "o")
    }

    @Test("Range subscripts return expected substrings")
    func rangeSubscripts() {
        let s = "hello world"
        #expect(s[0..<5] == "hello")
        #expect(s[6...10] == "world")
        #expect(s[6...] == "world")
        #expect(s[...4] == "hello")
        #expect(s[..<5] == "hello")
    }

    @Test("Substring subscripts mirror String behaviour")
    func substringSubscripts() {
        let s: Substring = "hello world"[0..<11]
        #expect(s[0] == "h")
        #expect(s[6...10] == "world")
        #expect(s[...4] == "hello")
    }
}
