import Foundation

public extension Dictionary where Key == String, Value == Any {
    /// Serialises a `[String: Any]` to a JSON string via `JSONSerialization`.
    /// Throws ``JSONError/notValidJSON`` when the dictionary contains values
    /// that cannot be serialised (`Date`, `URL`, custom types, etc.) and
    /// rethrows the underlying serialisation error otherwise.
    func asJSONString() throws -> String {
        guard JSONSerialization.isValidJSONObject(self) else {
            throw JSONError.notValidJSON
        }
        let data = try JSONSerialization.data(withJSONObject: self)
        return String(decoding: data, as: UTF8.self)
    }
}
