import Testing
@testable import HomerFoundation

@Suite("Sequence+Extensions")
struct SequenceExtensionsTests {
    @Test("uniqued preserves order while dropping duplicates")
    func uniqued() {
        #expect([1, 2, 2, 3, 1, 4].uniqued() == [1, 2, 3, 4])
        #expect([String]().uniqued() == [])
        #expect(["a", "b", "a", "c", "b"].uniqued() == ["a", "b", "c"])
    }

    @Test("uniqued(on:) drops duplicates by key path")
    func uniquedOnKeyPath() {
        struct User { let id: Int; let name: String }
        let users = [
            User(id: 1, name: "alice"),
            User(id: 2, name: "bob"),
            User(id: 1, name: "alice-dup"),
            User(id: 3, name: "carol")
        ]
        let result = users.uniqued(on: \.id)
        #expect(result.map(\.id) == [1, 2, 3])
        #expect(result.first?.name == "alice")
    }
}
