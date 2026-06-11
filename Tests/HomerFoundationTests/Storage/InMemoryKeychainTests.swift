import Foundation
import Testing
@testable import HomerFoundation

@Suite("InMemoryKeychain")
struct InMemoryKeychainTests {

    @Test("set then data round-trips the blob")
    func setThenGet() {
        let keychain = InMemoryKeychain()
        let blob = Data("secret".utf8)

        #expect(keychain.set(blob, forKey: "token"))
        #expect(keychain.data(forKey: "token") == blob)
    }

    @Test("data returns nil for a missing key")
    func missingKey() {
        #expect(InMemoryKeychain().data(forKey: "absent") == nil)
    }

    @Test("set overwrites an existing value")
    func overwrite() {
        let keychain = InMemoryKeychain()
        keychain.set(Data("old".utf8), forKey: "token")
        keychain.set(Data("new".utf8), forKey: "token")
        #expect(keychain.data(forKey: "token") == Data("new".utf8))
    }

    @Test("removeData deletes the key and is idempotent")
    func removal() {
        let keychain = InMemoryKeychain()
        keychain.set(Data("secret".utf8), forKey: "token")

        #expect(keychain.removeData(forKey: "token"))
        #expect(keychain.data(forKey: "token") == nil)
        #expect(keychain.removeData(forKey: "token"), "Removing a missing key is not an error")
    }

    @Test("removeAll empties the store")
    func removeAll() {
        let keychain = InMemoryKeychain()
        keychain.set(Data("a".utf8), forKey: "a")
        keychain.set(Data("b".utf8), forKey: "b")

        keychain.removeAll()

        #expect(keychain.data(forKey: "a") == nil)
        #expect(keychain.data(forKey: "b") == nil)
    }

    @Test("string convenience round-trips UTF-8 and rejects non-UTF-8 bytes")
    func stringConvenience() {
        let keychain = InMemoryKeychain()

        #expect(keychain.set("merhaba dünya", forKey: "greeting"))
        #expect(keychain.string(forKey: "greeting") == "merhaba dünya")

        keychain.set(Data([0xFF, 0xFE, 0xFD]), forKey: "binary")
        #expect(keychain.string(forKey: "binary") == nil)
    }

    @Test("concurrent writers do not corrupt the store")
    func concurrentAccess() async {
        let keychain = InMemoryKeychain()

        await withTaskGroup(of: Void.self) { group in
            for index in 0..<100 {
                group.addTask {
                    keychain.set(Data("value-\(index)".utf8), forKey: "key-\(index)")
                }
            }
        }

        for index in 0..<100 {
            #expect(keychain.data(forKey: "key-\(index)") == Data("value-\(index)".utf8))
        }
    }
}
