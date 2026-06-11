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

    @Test("asJSONString round-trips through Data.decoded")
    func asJSONStringRoundTrip() throws {
        let user = EncodableUser(id: 7, name: "alice")
        let json = try user.asJSONString()
        struct DecodedUser: Decodable, Equatable { let id: Int; let name: String }
        let decoded: DecodedUser = try Data(json.utf8).decoded()
        #expect(decoded == DecodedUser(id: 7, name: "alice"))
    }

    @Test("asJSONString honours custom encoder configuration")
    func asJSONStringCustomEncoder() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = try EncodableUser(id: 1, name: "bart").asJSONString(encoder: encoder)
        #expect(json == #"{"id":1,"name":"bart"}"#)
    }

    @Test("asJSONString encodes non-object top-level values too")
    func asJSONStringNonObject() throws {
        #expect(try [1, 2, 3].asJSONString() == "[1,2,3]")
    }
}

// MARK: - Helpers

private struct EncodableUser: Encodable {
    let id: Int
    let name: String
}
