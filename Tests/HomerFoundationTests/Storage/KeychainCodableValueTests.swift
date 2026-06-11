import Foundation
import Testing
@testable import HomerFoundation

private struct Session: Codable, Equatable, Sendable {
    let token: String
    let expiresAt: Date
}

@Suite("KeychainCodableValue")
struct KeychainCodableValueTests {

    @Test("returns the default when the key is missing")
    func missingKeyFallsBackToDefault() {
        let store = InMemoryKeychain()
        @KeychainCodableValue(key: "session", store: store)
        var session = Session(token: "default", expiresAt: Date(timeIntervalSince1970: 0))

        #expect(session.token == "default")
    }

    @Test("round-trips a Codable value through the store")
    func roundTrip() {
        let store = InMemoryKeychain()
        let stored = Session(token: "abc123", expiresAt: Date(timeIntervalSince1970: 1_000))
        @KeychainCodableValue(key: "session", store: store)
        var session: Session?

        session = stored
        #expect(session == stored)

        // A second wrapper over the same store sees the persisted value.
        @KeychainCodableValue(key: "session", store: store)
        var rehydrated: Session?
        #expect(rehydrated == stored)
    }

    @Test("assigning nil removes the item from the store")
    func nilAssignmentRemoves() {
        let store = InMemoryKeychain()
        @KeychainCodableValue(key: "token", store: store)
        var token: String?

        token = "secret"
        #expect(store.data(forKey: "token") != nil)

        token = nil
        #expect(store.data(forKey: "token") == nil)
        #expect(token == nil)
    }

    @Test("a corrupted blob falls back to the default instead of throwing")
    func corruptedBlobFallsBack() {
        let store = InMemoryKeychain()
        store.set(Data("not json".utf8), forKey: "session")

        @KeychainCodableValue(key: "session", store: store)
        var session = Session(token: "fallback", expiresAt: Date(timeIntervalSince1970: 0))

        #expect(session.token == "fallback")
    }

    @Test("optional shorthand init defaults to nil")
    func optionalShorthandInit() {
        let store = InMemoryKeychain()
        @KeychainCodableValue(key: "token", store: store)
        var token: String?

        #expect(token == nil)
    }

    @Test("custom encoder/decoder strategies are honoured")
    func customCoders() {
        let store = InMemoryKeychain()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        let stored = Session(token: "t", expiresAt: Date(timeIntervalSince1970: 1_000))
        @KeychainCodableValue(key: "session", store: store, encoder: encoder, decoder: decoder)
        var session: Session?
        session = stored

        #expect(session == stored)
        // The raw blob proves the strategy was applied (epoch number, not ISO string).
        let raw = store.string(forKey: "session")
        #expect(raw?.contains("1000") == true)
    }
}
