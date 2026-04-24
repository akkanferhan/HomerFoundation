import Testing
import Foundation
@testable import HomerFoundation

@Suite("Dictionary+Extensions")
struct DictionaryExtensionsTests {
    @Test("asJSONString returns valid JSON for serializable dictionary")
    func validJSON() throws {
        let dict: [String: Any] = ["id": 7, "name": "alice"]
        let json = try dict.asJSONString()
        let roundTripped = try Data(json.utf8).asJSONDictionary()
        #expect(roundTripped["id"] as? Int == 7)
        #expect(roundTripped["name"] as? String == "alice")
    }

    @Test("asJSONString throws notValidJSON for non-serializable values")
    func invalidJSON() {
        let dict: [String: Any] = ["date": Date()]
        #expect(throws: JSONError.notValidJSON) {
            _ = try dict.asJSONString()
        }
    }
}
