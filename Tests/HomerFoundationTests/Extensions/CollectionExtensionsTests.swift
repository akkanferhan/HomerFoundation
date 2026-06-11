import Foundation
import Testing
@testable import HomerFoundation

@Suite("Collection+Extensions")
struct CollectionExtensionsTests {
    @Test("isNotEmpty inverts isEmpty across collection types")
    func isNotEmpty() {
        #expect([1, 2].isNotEmpty)
        #expect(![Int]().isNotEmpty)
        #expect("a".isNotEmpty)
        #expect(!"".isNotEmpty)
        #expect(["k": 1].isNotEmpty)
        #expect(!Set<Int>().isNotEmpty)
    }

    @Test("subscript(safe:) returns element or nil for invalid index")
    func safeSubscript() {
        let array = [10, 20, 30]
        #expect(array[safe: 0] == 10)
        #expect(array[safe: 2] == 30)
        #expect(array[safe: 3] == nil)
        #expect(array[safe: -1] == nil)

        let empty: [Int] = []
        #expect(empty[safe: 0] == nil)
    }

    @Test("chunked(into:) splits into fixed-size chunks with a short tail")
    func chunked() {
        let array = [1, 2, 3, 4, 5, 6, 7]
        #expect(array.chunked(into: 3) == [[1, 2, 3], [4, 5, 6], [7]])
        #expect(array.chunked(into: 7) == [[1, 2, 3, 4, 5, 6, 7]])
        #expect(array.chunked(into: 10) == [[1, 2, 3, 4, 5, 6, 7]])
    }

    @Test("chunked(into:) returns [] for empty collections")
    func chunkedEmpty() {
        #expect([Int]().chunked(into: 3).isEmpty)
    }

    @Test("chunked(into:) clamps sizes below 1 instead of trapping or dropping")
    func chunkedClampsInvalidSize() {
        #expect([1, 2].chunked(into: 0) == [[1], [2]])
        #expect([1, 2].chunked(into: -5) == [[1], [2]])
    }

    @Test("chunked(into:) works on String, yielding character chunks")
    func chunkedString() {
        let chunks = "abcde".chunked(into: 2)
        #expect(chunks == [["a", "b"], ["c", "d"], ["e"]])
    }
}
