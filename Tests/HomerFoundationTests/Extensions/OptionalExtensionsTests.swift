import CoreGraphics
import Foundation
import Testing
@testable import HomerFoundation

@Suite("Optional+Extensions")
struct OptionalExtensionsTests {
    @Test("orEmpty returns wrapped collection or empty")
    func orEmpty() {
        let nilString: String? = nil
        let setString: String? = "x"
        #expect(nilString.orEmpty == "")
        #expect(setString.orEmpty == "x")

        let nilArray: [Int]? = nil
        let setArray: [Int]? = [1, 2]
        #expect(nilArray.orEmpty == [])
        #expect(setArray.orEmpty == [1, 2])
    }

    @Test("isNilOrEmpty / isNotNilOrEmpty on collections")
    func isNilOrEmpty() {
        let nilString: String? = nil
        let emptyString: String? = ""
        let setString: String? = "x"
        #expect(nilString.isNilOrEmpty)
        #expect(emptyString.isNilOrEmpty)
        #expect(!setString.isNilOrEmpty)
        #expect(setString.isNotNilOrEmpty)

        let nilArray: [Int]? = nil
        let emptyArray: [Int]? = []
        let setArray: [Int]? = [1]
        #expect(nilArray.isNilOrEmpty)
        #expect(emptyArray.isNilOrEmpty)
        #expect(setArray.isNotNilOrEmpty)
    }

    @Test("orZero on AdditiveArithmetic types")
    func orZero() {
        let nilInt: Int? = nil
        let setInt: Int? = 7
        #expect(nilInt.orZero == 0)
        #expect(setInt.orZero == 7)

        let nilDouble: Double? = nil
        let setDouble: Double? = 1.5
        #expect(nilDouble.orZero == 0.0)
        #expect(setDouble.orZero == 1.5)

        let nilCGFloat: CGFloat? = nil
        #expect(nilCGFloat.orZero == 0)
    }

    @Test("orFalse on Bool optionals")
    func orBool() {
        let nilBool: Bool? = nil
        let trueBool: Bool? = true
        #expect(nilBool.orFalse == false)
        #expect(trueBool.orFalse == true)
    }
}
