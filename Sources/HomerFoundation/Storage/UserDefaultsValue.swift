import Foundation

/// A property wrapper that persists a value to `UserDefaults`.
///
/// Stores property-list types only — `Data`, `String`, `Int`, `Double`, `Bool`,
/// `Date`, `Array` and `Dictionary` of those. For non-plist types like `URL`,
/// `UUID`, or any `Codable` struct, use ``UserDefaultsCodableValue``; assigning
/// a non-plist value to this wrapper triggers an assertion in debug builds and
/// is silently skipped in release.
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
            } else if PropertyListSerialization.propertyList(newValue, isValidFor: .binary) {
                store.set(newValue, forKey: key)
            } else {
                assertionFailure(
                    "UserDefaultsValue<\(Value.self)>: value is not a property-list type. Use UserDefaultsCodableValue for non-plist types like URL, UUID, or Codable structs."
                )
            }
        }
    }
}
