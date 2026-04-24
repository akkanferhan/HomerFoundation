import Testing
import Foundation
@testable import HomerFoundation

@Suite("Data+Extensions")
struct DataExtensionsTests {
    @Test("asJSONDictionary returns parsed dictionary for valid JSON object data")
    func validObject() throws {
        let data = Data(#"{"id":7,"name":"alice"}"#.utf8)
        let dict = try data.asJSONDictionary()
        #expect(dict["id"] as? Int == 7)
        #expect(dict["name"] as? String == "alice")
    }

    @Test("asJSONDictionary throws notADictionary for JSON arrays")
    func arrayThrows() {
        let data = Data("[1,2,3]".utf8)
        #expect(throws: JSONError.notADictionary) {
            _ = try data.asJSONDictionary()
        }
    }

    @Test("asJSONDictionary rethrows underlying parser error for invalid JSON")
    func invalidThrows() {
        let data = Data([0xFF, 0xFE, 0xFD])
        #expect(throws: Error.self) {
            _ = try data.asJSONDictionary()
        }
    }
}
