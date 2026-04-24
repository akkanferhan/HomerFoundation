import Testing
@testable import HomerFoundation

@Suite("Array+Extensions")
struct ArrayExtensionsTests {
    @Test("moveToFirst rearranges valid index, no-op for invalid")
    func moveToFirst() {
        var array = [10, 20, 30, 40]
        array.moveToFirst(from: 2)
        #expect(array == [30, 10, 20, 40])

        array.moveToFirst(from: 99)
        #expect(array == [30, 10, 20, 40])

        array.moveToFirst(from: -1)
        #expect(array == [30, 10, 20, 40])
    }

    @Test("removeFirstSafely returns nil on empty, element otherwise")
    func removeFirstSafely() {
        var array = [1, 2, 3]
        #expect(array.removeFirstSafely() == 1)
        #expect(array == [2, 3])

        var empty: [Int] = []
        #expect(empty.removeFirstSafely() == nil)
        #expect(empty.isEmpty)
    }
}
