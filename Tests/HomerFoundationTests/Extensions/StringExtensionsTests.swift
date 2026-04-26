import Foundation
import Testing
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

    @Test("parsedWords and wordCount split on any whitespace")
    func words() {
        #expect("hello world foo".parsedWords == ["hello", "world", "foo"])
        #expect("hello world foo".wordCount == 3)
        #expect("".wordCount == 0)
        #expect("single".wordCount == 1)
    }

    @Test("parsedWords collapses tabs, newlines, and consecutive whitespace")
    func wordsWithMixedWhitespace() {
        #expect("hello\tworld".parsedWords == ["hello", "world"])
        #expect("a\nb\nc".wordCount == 3)
        #expect("foo   bar".parsedWords == ["foo", "bar"])
        #expect("  leading and trailing  ".parsedWords == ["leading", "and", "trailing"])
    }

    @Test("withTurkishTransliteration replaces Turkish-specific characters")
    func turkishTransliteration() {
        #expect("Çığlık".withTurkishTransliteration == "Ciglik")
        #expect("şöğüı".withTurkishTransliteration == "sogui")
        #expect("İSTANBUL".withTurkishTransliteration == "ISTANBUL")
    }

    @Test("asDouble parses decimal literals or returns nil")
    func asDouble() {
        #expect("3.14".asDouble == 3.14)
        #expect("-2".asDouble == -2.0)
        #expect("".asDouble == nil)
        #expect("not a number".asDouble == nil)
    }

    @Test("asURL builds URL from valid string or returns nil")
    func asURL() {
        #expect("https://example.com/path".asURL?.absoluteString == "https://example.com/path")
        #expect("relative/path".asURL != nil)
        #expect("".asURL == nil)
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

    @Test("nilIfEmpty returns nil only for the empty string")
    func nilIfEmpty() {
        #expect("".nilIfEmpty == nil)
        #expect("hello".nilIfEmpty == "hello")
        // Whitespace-only strings are not considered empty here — use `trimmedOrNil`.
        #expect("   ".nilIfEmpty == "   ")
    }

    @Test("trimmedOrNil returns nil for empty and whitespace-only input")
    func trimmedOrNil() {
        #expect("".trimmedOrNil == nil)
        #expect("   ".trimmedOrNil == nil)
        #expect("\n\t".trimmedOrNil == nil)
        #expect(" hello ".trimmedOrNil == "hello")
        #expect("hello".trimmedOrNil == "hello")
    }
}
