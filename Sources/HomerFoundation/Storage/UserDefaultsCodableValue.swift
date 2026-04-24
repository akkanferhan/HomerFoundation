import Foundation

/// A property wrapper that persists any `Codable` value to `UserDefaults` by
/// serialising it through `JSONEncoder`.
///
/// Use this for non-plist types like `URL`, `UUID`, enums with associated
/// values, or your own `Codable` structs. For plist-native types
/// (`String`, `Int`, `Data`, `Date`, …) prefer ``UserDefaultsValue`` so the
/// system can use its native fast-path.
///
/// On read, a missing key or a decode failure (corrupted blob, schema
/// migration, etc.) silently returns `defaultValue`. On write, assigning
/// `nil` for an `Optional` `Value` removes the key.
@propertyWrapper
public struct UserDefaultsCodableValue<Value: Codable & Sendable>: @unchecked Sendable {
    /// The defaults key under which the encoded value is stored.
    public let key: String
    /// The value returned when the key is missing or its data fails to decode.
    public let defaultValue: Value
    /// The backing `UserDefaults` store. Defaults to `.standard`.
    public let store: UserDefaults
    /// Encoder used to write the value. Configure for custom date/key strategies.
    public let encoder: JSONEncoder
    /// Decoder used to read the value. Configure to mirror the encoder.
    public let decoder: JSONDecoder

    /// Creates a wrapper with an inline default and an injectable store.
    /// - Parameters:
    ///   - wrappedValue: The fallback value used when the key is missing or
    ///     decoding fails.
    ///   - key: The defaults key.
    ///   - store: The `UserDefaults` instance to read/write through.
    ///   - encoder: Customise dating, key, or output formatting strategies.
    ///   - decoder: Customise parsing strategies (must match the encoder).
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
