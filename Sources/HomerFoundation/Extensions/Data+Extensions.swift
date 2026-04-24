import Foundation

public extension Data {
    func asJSONDictionary() throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: self)
        guard let dictionary = object as? [String: Any] else {
            throw JSONError.notADictionary
        }
        return dictionary
    }
}
