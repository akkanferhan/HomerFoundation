import Foundation

/// Abstraction over a secure key/value store for small secrets (tokens,
/// credentials, identifiers).
///
/// Conformers map string keys to `Data` blobs. The production conformer
/// is ``Keychain`` (backed by the Security framework); tests and SwiftUI
/// previews inject ``InMemoryKeychain`` so no real keychain entitlement
/// or user keychain is touched. ``KeychainCodableValue`` accepts any
/// conformer, mirroring how `UserDefaultsValue` takes an injectable
/// `UserDefaults`.
public protocol KeychainStoring: Sendable {
    /// Returns the blob stored for `key`, or `nil` when the key is
    /// missing (or the underlying store failed to read).
    func data(forKey key: String) -> Data?

    /// Stores `data` under `key`, overwriting any existing value.
    /// - Returns: `true` when the value was persisted.
    @discardableResult
    func set(_ data: Data, forKey key: String) -> Bool

    /// Removes the value stored under `key`. Removing a missing key is
    /// not an error.
    /// - Returns: `true` when the key is absent after the call.
    @discardableResult
    func removeData(forKey key: String) -> Bool
}

public extension KeychainStoring {
    /// Returns the UTF-8 string stored for `key`, or `nil` when the key
    /// is missing or its bytes are not valid UTF-8. Convenience for the
    /// most common secret shape — bearer tokens and the like.
    func string(forKey key: String) -> String? {
        data(forKey: key).flatMap { String(data: $0, encoding: .utf8) }
    }

    /// Stores `string` under `key` as UTF-8 bytes, overwriting any
    /// existing value.
    /// - Returns: `true` when the value was persisted.
    @discardableResult
    func set(_ string: String, forKey key: String) -> Bool {
        set(Data(string.utf8), forKey: key)
    }
}
