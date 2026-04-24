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
            throw EncodingError.invalidValue(
                self,
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Encoded value is not a JSON object."
                )
            )
        }
        return dictionary
    }
}
