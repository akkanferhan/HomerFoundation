import Testing
@testable import HomerFoundation

@Suite("Typealiases/Completions")
struct CompletionsTests {
    @Test("VoidCompletion can be assigned and invoked")
    func voidCompletion() {
        var fired = false
        let completion: VoidCompletion = { fired = true }
        completion()
        #expect(fired)
    }

    @Test("ValueCompletion delivers the wrapped value")
    func valueCompletion() {
        var captured: Int = 0
        let completion: ValueCompletion<Int> = { captured = $0 }
        completion(42)
        #expect(captured == 42)
    }

    @Test("Parameters is a [String: Any] alias")
    func parameters() {
        let payload: Parameters = ["id": 7, "name": "alice", "active": true]
        #expect(payload["id"] as? Int == 7)
        #expect(payload["name"] as? String == "alice")
        #expect(payload["active"] as? Bool == true)
    }
}
