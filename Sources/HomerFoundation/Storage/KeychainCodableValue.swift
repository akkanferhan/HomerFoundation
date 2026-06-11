import Foundation

/// A property wrapper that persists any `Codable` value to the keychain
/// by serialising it through `JSONEncoder`.
///
/// The secure sibling of ``UserDefaultsCodableValue`` — same forgiving
/// contract, different backing store. Use it for secrets that must not
/// live in plain-text defaults: tokens, credentials, device secrets.
///
/// ```swift
/// struct SessionStore {
///     @KeychainCodableValue(key: "auth.session")
///     var session: AuthSession?
/// }
/// ```
///
/// On read, a missing key or a decode failure (corrupted blob, schema
/// migration) silently returns `defaultValue`. On write, assigning
/// `nil` for an `Optional` `Value` removes the item. Inject an
/// ``InMemoryKeychain`` in tests to avoid touching the real keychain.
@propertyWrapper
public struct KeychainCodableValue<Value: Codable & Sendable>: @unchecked Sendable {
    /// The account key the encoded value is stored under.
    public let key: String
    /// The value returned when the key is missing or its data fails to decode.
    public let defaultValue: Value
    /// The backing store. Defaults to a ``Keychain`` scoped to the host
    /// bundle identifier.
    public let store: any KeychainStoring
    /// Encoder used to write the value. Configure for custom date/key strategies.
    public let encoder: JSONEncoder
    /// Decoder used to read the value. Configure to mirror the encoder.
    public let decoder: JSONDecoder

    /// Creates a wrapper with an inline default and an injectable store.
    /// - Parameters:
    ///   - wrappedValue: The fallback value used when the key is missing
    ///     or decoding fails.
    ///   - key: The keychain account key.
    ///   - store: The ``KeychainStoring`` conformer to read/write
    ///     through. Defaults to ``Keychain``; inject ``InMemoryKeychain``
    ///     in tests.
    ///   - encoder: Customise dating, key, or output formatting strategies.
    ///   - decoder: Customise parsing strategies (must match the encoder).
    public init(
        wrappedValue: Value,
        key: String,
        store: any KeychainStoring = Keychain(),
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.key = key
        self.defaultValue = wrappedValue
        self.store = store
        self.encoder = encoder
        self.decoder = decoder
    }

    /// Decodes from / encodes into the underlying store. A missing key
    /// or a failed decode silently returns ``defaultValue``. Assigning
    /// `nil` to an `Optional` `Value` removes the item; encoder errors
    /// on write are silently dropped.
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
                store.removeData(forKey: key)
            } else if let data = try? encoder.encode(newValue) {
                store.set(data, forKey: key)
            }
        }
    }
}

public extension KeychainCodableValue where Value: ExpressibleByNilLiteral {
    /// Creates a wrapper for an `Optional` value whose default is `nil`,
    /// allowing `@KeychainCodableValue(key: "auth.token") var token: String?`
    /// without spelling out `wrappedValue: nil`.
    init(
        key: String,
        store: any KeychainStoring = Keychain(),
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.init(wrappedValue: nil, key: key, store: store, encoder: encoder, decoder: decoder)
    }
}
