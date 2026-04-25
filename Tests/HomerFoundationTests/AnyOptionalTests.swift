import Testing
@testable import HomerFoundation

@Suite("AnyOptional")
struct AnyOptionalTests {
    @Test("nil optional reports isNil true and isNotNil false")
    func nilOptional() {
        let value: Int? = nil
        #expect(value.isNil)
        #expect(!value.isNotNil)
    }

    @Test("non-nil optional reports isNotNil true and isNil false")
    func nonNilOptional() {
        let value: Int? = 42
        #expect(!value.isNil)
        #expect(value.isNotNil)
    }

    @Test("AnyOptional check works through generic constraint")
    func genericNilCheck() {
        func isWrappedNil<T>(_ value: T?) -> Bool { value.isNil }
        #expect(isWrappedNil(Int?.none))
        #expect(!isWrappedNil(Optional("x")))
    }
}
