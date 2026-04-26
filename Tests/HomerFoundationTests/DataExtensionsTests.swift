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

    @Test("append(_:encoding:) appends UTF-8 bytes by default and reports success")
    func appendStringDefault() {
        var data = Data()
        let ok = data.append("hello")
        #expect(ok)
        #expect(String(data: data, encoding: .utf8) == "hello")

        let ok2 = data.append(" world")
        #expect(ok2)
        #expect(String(data: data, encoding: .utf8) == "hello world")
    }

    @Test("append(_:encoding:) returns false and leaves data untouched when string is not representable")
    func appendStringIncompatibleEncoding() {
        var data = Data("seed".utf8)
        let snapshot = data
        let ok = data.append("çığlık", encoding: .ascii)
        #expect(!ok)
        #expect(data == snapshot)
    }
}
