import Foundation
import Testing
@testable import HomerFoundation

@Suite("PreviewReachability")
@MainActor
struct PreviewReachabilityTests {
    @Test("Default init reports a connected wifi state")
    func defaultInit() {
        let preview = PreviewReachability()
        #expect(preview.isConnected)
        #expect(preview.connectionType == .wifi)
    }

    @Test("Custom init forwards the supplied state")
    func customInit() {
        let preview = PreviewReachability(isConnected: false, connectionType: .unavailable)
        #expect(!preview.isConnected)
        #expect(preview.connectionType == .unavailable)
    }

    @Test("State is mutable so tests can simulate transitions")
    func mutableState() {
        let preview = PreviewReachability(isConnected: true, connectionType: .wifi)
        preview.isConnected = false
        preview.connectionType = .unavailable
        #expect(!preview.isConnected)
        #expect(preview.connectionType == .unavailable)
    }

    @Test("start and stop are no-ops and never mutate state")
    func startStopAreNoOps() {
        let preview = PreviewReachability(isConnected: true, connectionType: .cellular)
        preview.start()
        preview.start()
        preview.stop()
        preview.stop()
        #expect(preview.isConnected)
        #expect(preview.connectionType == .cellular)
    }

    @Test("PreviewReachability satisfies any ReachabilityProviding")
    func protocolConformance() {
        let provider: any ReachabilityProviding = PreviewReachability(
            isConnected: false,
            connectionType: .unavailable
        )
        #expect(!provider.isConnected)
        #expect(provider.connectionType == .unavailable)
    }
}
