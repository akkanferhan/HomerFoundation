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
}
