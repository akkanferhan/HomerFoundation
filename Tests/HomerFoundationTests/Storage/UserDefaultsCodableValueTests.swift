import Foundation
import Testing
@testable import HomerFoundation

@Suite("UserDefaultsCodableValue")
struct UserDefaultsCodableValueTests {
    private func makeStore(function: String = #function) -> UserDefaults {
        let suite = "com.homer.tests.codable.\(function).\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suite)!
        store.removePersistentDomain(forName: suite)
        return store
    }

    @Test("Default value is returned when key is missing")
    func defaultValue() {
        let store = makeStore()
        let fallback = CodableProfile(id: 0, name: "anonymous")
        let wrapper = UserDefaultsCodableValue(wrappedValue: fallback, key: "profile", store: store)
        #expect(wrapper.wrappedValue == fallback)
    }

    @Test("Codable struct round-trips through the wrapper")
    func roundTrip() {
        let store = makeStore()
        var wrapper = UserDefaultsCodableValue(
            wrappedValue: CodableProfile(id: 0, name: "anon"),
            key: "profile",
            store: store
        )
        let updated = CodableProfile(id: 7, name: "alice")
        wrapper.wrappedValue = updated
        #expect(wrapper.wrappedValue == updated)
    }

    @Test("Default value is returned when stored data is corrupt")
    func corruptDataFallsBackToDefault() {
        let store = makeStore()
        let fallback = CodableProfile(id: 0, name: "anon")
        store.set(Data([0xFF, 0xFE, 0xFD]), forKey: "profile")
        let wrapper = UserDefaultsCodableValue(wrappedValue: fallback, key: "profile", store: store)
        #expect(wrapper.wrappedValue == fallback)
    }

    @Test("Setting nil on optional Value removes the key")
    func optionalNilRemovesKey() {
        let store = makeStore()
        var wrapper = UserDefaultsCodableValue<CodableProfile?>(wrappedValue: nil, key: "profile", store: store)
        wrapper.wrappedValue = CodableProfile(id: 1, name: "bob")
        #expect(store.data(forKey: "profile") != nil)
        wrapper.wrappedValue = nil
        #expect(store.data(forKey: "profile") == nil)
    }

    @Test("Custom encoder/decoder configuration is respected")
    func customCoder() {
        struct Item: Codable, Equatable { let createdAt: Date }
        let store = makeStore()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        var wrapper = UserDefaultsCodableValue(
            wrappedValue: Item(createdAt: Date(timeIntervalSince1970: 0)),
            key: "item",
            store: store,
            encoder: encoder,
            decoder: decoder
        )
        let item = Item(createdAt: Date(timeIntervalSince1970: 1000))
        wrapper.wrappedValue = item
        #expect(wrapper.wrappedValue == item)
    }
}

// MARK: - Helpers

private struct CodableProfile: Codable, Equatable {
    let id: Int
    let name: String
}
