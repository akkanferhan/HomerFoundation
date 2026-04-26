import Foundation
import Testing
@testable import HomerFoundation

@Suite("PhoneNumberFormatter")
struct PhoneNumberFormatterTests {
    @Test("Empty input returns empty string")
    func emptyInput() {
        let formatter = PhoneNumberFormatter(format: .international)
        #expect(formatter.format("") == "")
        #expect(formatter.format("abc") == "")
    }

    @Test("National format produces standard Turkish layout")
    func nationalFormat() {
        let formatter = PhoneNumberFormatter(format: .national)
        #expect(formatter.format("5551234567") == "(555) 123 45 67")
    }

    @Test("Leading zero is stripped by default")
    func stripsLeadingZeroByDefault() {
        let formatter = PhoneNumberFormatter(format: .national)
        #expect(formatter.format("05551234567") == "(555) 123 45 67")
    }

    @Test("Leading zero retained when stripsLeadingZero is false")
    func keepsLeadingZeroWhenDisabled() {
        let formatter = PhoneNumberFormatter(format: .national, stripsLeadingZero: false)
        #expect(formatter.format("05551234567") == "(055) 512 34 56")
    }

    @Test("International format includes country prefix slot")
    func internationalFormat() {
        let formatter = PhoneNumberFormatter(format: .international)
        #expect(formatter.format("905551234567") == "+90 (555) 123-4567")
    }

    @Test("Non-digit characters are stripped from input")
    func stripsNonDigits() {
        let formatter = PhoneNumberFormatter(format: .national)
        #expect(formatter.format("(555) 123-45-67") == "(555) 123 45 67")
    }

    @Test("Partial input produces partial mask output")
    func partialInput() {
        let formatter = PhoneNumberFormatter(format: .national)
        #expect(formatter.format("555") == "(555")
        #expect(formatter.format("55512") == "(555) 12")
    }

    @Test("Custom mask is honoured")
    func customMask() {
        let format = PhoneNumberFormat(mask: "##-##-##")
        let formatter = PhoneNumberFormatter(format: format, stripsLeadingZero: false)
        #expect(formatter.format("123456") == "12-34-56")
    }

    @Test("Excess digits beyond mask capacity are truncated")
    func truncatesExcess() {
        let formatter = PhoneNumberFormatter(format: .national)
        #expect(formatter.format("55512345678901234") == "(555) 123 45 67")
    }
}
