import Foundation

public extension Data {
    /// Parses the data as a JSON object. Throws ``JSONError/notADictionary``
    /// if the top-level value is an array or scalar; rethrows underlying
    /// `JSONSerialization` errors for malformed input.
    func asJSONDictionary() throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: self)
        guard let dictionary = object as? [String: Any] else {
            throw JSONError.notADictionary
        }
        return dictionary
    }

    /// Decodes the bytes as JSON into `type`. The inverse of
    /// `Encodable.asJSONString(encoder:)`; the type usually infers from
    /// context — `let user: User = try data.decoded()`. Rethrows the
    /// decoder's error.
    /// - Parameters:
    ///   - type: The `Decodable` type to produce. Defaults to the
    ///     contextual type.
    ///   - decoder: Customise key/date strategies; defaults to
    ///     `JSONDecoder()`.
    func decoded<T: Decodable>(as type: T.Type = T.self, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(T.self, from: self)
    }

    /// Appends `string` encoded with `encoding`. Returns `false` and leaves the
    /// receiver untouched when the string cannot be represented in the chosen
    /// encoding (e.g. non-ASCII content with `.ascii`); returns `true` on
    /// success. Useful for building multipart bodies and other text-over-bytes
    /// payloads.
    @discardableResult
    mutating func append(_ string: String, encoding: String.Encoding = .utf8) -> Bool {
        guard let encoded = string.data(using: encoding) else { return false }
        append(encoded)
        return true
    }
}
