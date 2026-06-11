import Foundation
import Testing
@testable import HomerFoundation

@Suite("Encodable+Extensions")
struct EncodableExtensionsTests {
    @Test("asDictionary round-trips Codable values to a dictionary")
    func asDictionary() throws {
        let user = EncodableUser(id: 7, name: "alice")
        let dict = try user.asDictionary()
        #expect(dict["id"] as? Int == 7)
        #expect(dict["name"] as? String == "alice")
    }

    @Test("asDictionary throws JSONError.notADictionary when encoded value is not a JSON object")
    func asDictionaryThrowsForNonObject() {
        let array = [1, 2, 3]
        #expect(throws: JSONError.notADictionary) {
            _ = try array.asDictionary()
        }
    }

    @Test("asDictionary honours custom encoder configuration")
    func customEncoder() throws {
        struct Item: Encodable { let createdAt: Date }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let item = Item(createdAt: Date(timeIntervalSince1970: 1000))
        let dict = try item.asDictionary(encoder: encoder)
        #expect(dict["createdAt"] as? Double == 1000)
    }
}

// MARK: - Helpers

private struct EncodableUser: Encodable {
    let id: Int
    let name: String
}
