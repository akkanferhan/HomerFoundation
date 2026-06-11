import Foundation
import Security

/// When the system allows a ``Keychain`` item to be read. Wraps the
/// `kSecAttrAccessible*` constants in a `Sendable` enum.
public enum KeychainAccessibility: Sendable {
    /// Readable only while the device is unlocked. Most restrictive
    /// option that still suits foreground-only apps.
    case whenUnlocked
    /// Readable from first unlock after boot until restart — the usual
    /// choice for tokens refreshed by background work.
    case afterFirstUnlock
    /// Like ``whenUnlocked``, but never migrates to a new device via
    /// backup restore.
    case whenUnlockedThisDeviceOnly
    /// Like ``afterFirstUnlock``, but never migrates to a new device via
    /// backup restore.
    case afterFirstUnlockThisDeviceOnly

    var secValue: CFString {
        switch self {
        case .whenUnlocked: kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock
        case .whenUnlockedThisDeviceOnly: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        }
    }
}

/// ``KeychainStoring`` conformer backed by the Security framework's
/// generic-password item class.
///
/// Items are scoped by `service` (one namespace per wrapper, defaulting
/// to the host bundle identifier) and keyed by `kSecAttrAccount`. The
/// API is deliberately small and non-throwing — reads return `nil` and
/// writes report `Bool` — matching the forgiving contract of the
/// `UserDefaults` wrappers in this library. Inspect the keychain with
/// the Security CLI or Keychain Access when a write unexpectedly
/// returns `false` (most commonly a missing keychain entitlement or,
/// on macOS, a locked keychain).
///
/// Unit tests should inject ``InMemoryKeychain`` instead — SecItem
/// calls require host-app entitlements that plain test runners and CI
/// machines typically lack.
public struct Keychain: KeychainStoring {
    /// The `kSecAttrService` namespace items are stored under.
    public let service: String
    /// Optional `kSecAttrAccessGroup` for sharing items across apps of
    /// the same team. `nil` (the default) stores in the app's own group.
    public let accessGroup: String?
    /// When the system allows the stored items to be read. Applied to
    /// newly created items; existing items keep their original setting.
    public let accessibility: KeychainAccessibility

    /// Creates a store scoped to `service`.
    /// - Parameters:
    ///   - service: Namespace for the items. Defaults to the host
    ///     bundle's identifier (falling back to `"HomerFoundation"` in
    ///     contexts without one, e.g. command-line tools).
    ///   - accessGroup: Keychain access group for cross-app sharing.
    ///   - accessibility: Read availability for newly created items.
    public init(
        service: String? = nil,
        accessGroup: String? = nil,
        accessibility: KeychainAccessibility = .afterFirstUnlock
    ) {
        self.service = service ?? Bundle.main.bundleIdentifier ?? Constants.Keychain.fallbackService
        self.accessGroup = accessGroup
        self.accessibility = accessibility
    }

    public func data(forKey key: String) -> Data? {
        var query = baseQuery(forKey: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    @discardableResult
    public func set(_ data: Data, forKey key: String) -> Bool {
        // Update-first: the common case for tokens is refreshing an
        // existing item, and SecItemAdd would fail with errSecDuplicateItem.
        let attributes: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(baseQuery(forKey: key) as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess { return true }
        guard updateStatus == errSecItemNotFound else { return false }

        var addQuery = baseQuery(forKey: key)
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = accessibility.secValue
        return SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess
    }

    @discardableResult
    public func removeData(forKey key: String) -> Bool {
        let status = SecItemDelete(baseQuery(forKey: key) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    private func baseQuery(forKey key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        return query
    }
}
