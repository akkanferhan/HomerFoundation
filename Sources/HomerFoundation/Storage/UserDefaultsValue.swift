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
    /// The defaults key under which the value is stored.
    public let key: String
    /// The fallback returned when the key is missing or the stored object cannot
    /// be cast to `Value`.
    public let defaultValue: Value
    /// The backing `UserDefaults` store. Defaults to `.standard`.
    public let store: UserDefaults

    /// Creates a wrapper with an inline default and an injectable store.
    /// - Parameters:
    ///   - wrappedValue: The fallback value used when the key is missing or
    ///     the stored object cannot be cast to `Value`.
    ///   - key: The defaults key.
    ///   - store: The `UserDefaults` instance to read/write through. Defaults
    ///     to `.standard`; pass an app-group store for shared containers.
    public init(wrappedValue: Value, key: String, store: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = wrappedValue
        self.store = store
    }

    /// Reads from / writes to the underlying store. Assigning `nil` to an
    /// `Optional` `Value` removes the key. Non-plist values trigger an
    /// `assertionFailure` in debug builds and are silently dropped in release.
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
