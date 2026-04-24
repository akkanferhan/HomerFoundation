import Foundation

public extension Dictionary where Key == String, Value == Any {
    func asJSONString() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
