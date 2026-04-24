import Testing
import Foundation
@testable import HomerFoundation

@Suite("UserDefaultsValue")
struct UserDefaultsValueTests {
    private func makeStore(function: String = #function) -> UserDefaults {
        let suite = "com.homer.tests.\(function).\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suite)!
        store.removePersistentDomain(forName: suite)
        return store
    }

    @Test("Default value is returned when key is missing")
    func defaultValue() {
        let store = makeStore()
        let wrapper = UserDefaultsValue(wrappedValue: "system", key: "theme", store: store)
        #expect(wrapper.wrappedValue == "system")
    }

    @Test("Setting wrappedValue persists to the underlying store")
    func setPersists() {
        let store = makeStore()
        var wrapper = UserDefaultsValue(wrappedValue: "system", key: "theme", store: store)
        wrapper.wrappedValue = "dark"
        #expect(wrapper.wrappedValue == "dark")
        #expect(store.string(forKey: "theme") == "dark")
    }

    @Test("Setting nil on an optional Value removes the key")
    func optionalNilRemovesKey() {
        let store = makeStore()
        var wrapper = UserDefaultsValue<String?>(wrappedValue: nil, key: "token", store: store)
        wrapper.wrappedValue = "abc"
        #expect(store.string(forKey: "token") == "abc")
        wrapper.wrappedValue = nil
        #expect(store.object(forKey: "token") == nil)
    }

    @Test("Wrapper round-trips primitive types")
    func primitiveRoundTrip() {
        let store = makeStore()
        var intWrapper = UserDefaultsValue(wrappedValue: 0, key: "count", store: store)
        intWrapper.wrappedValue = 42
        #expect(intWrapper.wrappedValue == 42)

        var boolWrapper = UserDefaultsValue(wrappedValue: false, key: "enabled", store: store)
        boolWrapper.wrappedValue = true
        #expect(boolWrapper.wrappedValue == true)

        var doubleWrapper = UserDefaultsValue(wrappedValue: 0.0, key: "ratio", store: store)
        doubleWrapper.wrappedValue = 1.5
        #expect(doubleWrapper.wrappedValue == 1.5)
    }

    @Test("Independent stores do not leak values between wrappers")
    func storeIsolation() {
        let storeA = makeStore()
        let storeB = makeStore()
        var wrapperA = UserDefaultsValue(wrappedValue: "a", key: "shared", store: storeA)
        let wrapperB = UserDefaultsValue(wrappedValue: "b", key: "shared", store: storeB)
        wrapperA.wrappedValue = "changed"
        #expect(wrapperA.wrappedValue == "changed")
        #expect(wrapperB.wrappedValue == "b")
    }
}
