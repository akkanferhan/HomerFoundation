import Foundation

/// Dictionary-backed ``KeychainStoring`` stub for unit tests and SwiftUI
/// previews.
///
/// Behaves like ``Keychain`` from the caller's perspective — overwrite
/// on `set`, `nil` for missing keys, idempotent removal — without
/// touching the real keychain, so tests need no entitlements and leave
/// no residue behind. The companion to ``PreviewReachability`` in this
/// library's "inject a stub" pattern.
///
/// An `NSLock` guards the storage dictionary, so a single instance can
/// be shared across concurrent test tasks; hence `@unchecked Sendable`.
public final class InMemoryKeychain: KeychainStoring, @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: Data] = [:]

    /// Creates an empty store.
    public init() {}

    public func data(forKey key: String) -> Data? {
        lock.withLock { storage[key] }
    }

    @discardableResult
    public func set(_ data: Data, forKey key: String) -> Bool {
        lock.withLock { storage[key] = data }
        return true
    }

    @discardableResult
    public func removeData(forKey key: String) -> Bool {
        lock.withLock { storage[key] = nil }
        return true
    }

    /// Empties the store. Convenience for test teardown when an
    /// instance is reused across cases.
    public func removeAll() {
        lock.withLock { storage.removeAll() }
    }
}
