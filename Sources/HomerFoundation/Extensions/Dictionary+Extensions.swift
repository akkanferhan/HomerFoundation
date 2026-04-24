import Foundation

public extension Dictionary where Key == String, Value == Any {
    func asJSONString() throws -> String {
        guard JSONSerialization.isValidJSONObject(self) else {
            throw JSONError.notValidJSON
        }
        let data = try JSONSerialization.data(withJSONObject: self)
        return String(decoding: data, as: UTF8.self)
    }
}
