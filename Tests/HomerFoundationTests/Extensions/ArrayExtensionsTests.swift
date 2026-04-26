import Foundation
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

    @Test("subscript(safe:) returns element for valid index")
    func safeSubscriptValidIndex() {
        let array = [10, 20, 30]
        #expect(array[safe: 0] == 10)
        #expect(array[safe: 1] == 20)
        #expect(array[safe: 2] == 30)
    }

    @Test("subscript(safe:) returns nil for out-of-bounds index", arguments: [3, 4, 100])
    func safeSubscriptOutOfBounds(index: Int) {
        let array = [10, 20, 30]
        #expect(array[safe: index] == nil)
    }

    @Test("subscript(safe:) returns nil for negative index")
    func safeSubscriptNegativeIndex() {
        let array = [10, 20, 30]
        #expect(array[safe: -1] == nil)
    }

    @Test("subscript(safe:) returns nil for any index on empty array", arguments: [-1, 0, 1])
    func safeSubscriptEmptyArray(index: Int) {
        let empty: [Int] = []
        #expect(empty[safe: index] == nil)
    }

    @Test("subscript(safe:) on single-element array returns element at 0 and nil at 1")
    func safeSubscriptSingleElement() {
        let array = [42]
        #expect(array[safe: 0] == 42)
        #expect(array[safe: 1] == nil)
    }
}
