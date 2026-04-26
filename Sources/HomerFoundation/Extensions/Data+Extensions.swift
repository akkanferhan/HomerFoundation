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
