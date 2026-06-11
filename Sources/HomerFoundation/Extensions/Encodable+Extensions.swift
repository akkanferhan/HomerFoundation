import Foundation

public extension Encodable {
    /// Encodes through `JSONEncoder` then re-parses as `[String: Any]`.
    /// Throws `JSONError.notADictionary` when the encoded value is not a JSON
    /// object (arrays, single values, etc.) or rethrows the encoder's error.
    /// - Parameter encoder: Customise key/date strategies; defaults to
    ///   `JSONEncoder()`.
    func asDictionary(encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw JSONError.notADictionary
        }
        return dictionary
    }

    /// Encodes through `JSONEncoder` and decodes the bytes as a UTF-8
    /// string. Completes the JSON bridge family alongside
    /// ``asDictionary(encoder:)``, `Data.asJSONDictionary()`, and
    /// `Dictionary.asJSONString()`. Rethrows the encoder's error.
    /// - Parameter encoder: Customise key/date strategies; defaults to
    ///   `JSONEncoder()`.
    func asJSONString(encoder: JSONEncoder = JSONEncoder()) throws -> String {
        let data = try encoder.encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}
