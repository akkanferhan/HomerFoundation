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
}
