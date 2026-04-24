import Foundation

@propertyWrapper
public struct UserDefaultsCodableValue<Value: Codable & Sendable>: @unchecked Sendable {
    public let key: String
    public let defaultValue: Value
    public let store: UserDefaults
    public let encoder: JSONEncoder
    public let decoder: JSONDecoder

    public init(
        wrappedValue: Value,
        key: String,
        store: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.key = key
        self.defaultValue = wrappedValue
        self.store = store
        self.encoder = encoder
        self.decoder = decoder
    }

    public var wrappedValue: Value {
        get {
            guard
                let data = store.data(forKey: key),
                let value = try? decoder.decode(Value.self, from: data)
            else {
                return defaultValue
            }
            return value
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                store.removeObject(forKey: key)
            } else if let data = try? encoder.encode(newValue) {
                store.set(data, forKey: key)
            }
        }
    }
}
