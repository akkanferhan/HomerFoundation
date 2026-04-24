import Foundation

@propertyWrapper
public struct UserDefaultsValue<Value: Sendable>: @unchecked Sendable {
    public let key: String
    public let defaultValue: Value
    public let store: UserDefaults

    public init(wrappedValue: Value, key: String, store: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = wrappedValue
        self.store = store
    }

    public var wrappedValue: Value {
        get { store.object(forKey: key) as? Value ?? defaultValue }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                store.removeObject(forKey: key)
            } else {
                store.set(newValue, forKey: key)
            }
        }
    }
}
