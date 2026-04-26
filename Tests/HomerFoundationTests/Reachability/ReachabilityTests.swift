import Foundation
import Testing
@testable import HomerFoundation

@Suite("Reachability")
@MainActor
struct ReachabilityTests {
    @Test("Initial state is disconnected and unavailable")
    func initialState() {
        let reachability = Reachability()
        #expect(!reachability.isConnected)
        #expect(reachability.connectionType == .unavailable)
    }

    @Test("start and stop do not crash and can be repeated")
    func startStopCycle() {
        let reachability = Reachability()
        reachability.start()
        reachability.stop()
        reachability.start()
        reachability.stop()
    }

    @Test("connectionType derivation: unsatisfied path is unavailable")
    func unsatisfiedIsUnavailable() {
        #expect(Reachability.connectionType(isSatisfied: false) == .unavailable)
        #expect(Reachability.connectionType(isSatisfied: false, wifi: true) == .unavailable)
    }

    @Test("connectionType derivation: wifi wins when present")
    func wifiWins() {
        #expect(Reachability.connectionType(isSatisfied: true, wifi: true) == .wifi)
        #expect(Reachability.connectionType(isSatisfied: true, wifi: true, cellular: true) == .wifi)
    }

    @Test("connectionType derivation: cellular when no wifi")
    func cellular() {
        #expect(Reachability.connectionType(isSatisfied: true, cellular: true) == .cellular)
    }

    @Test("connectionType derivation: wired when no wifi or cellular")
    func wired() {
        #expect(Reachability.connectionType(isSatisfied: true, wired: true) == .wired)
    }

    @Test("connectionType derivation: satisfied with no flagged interface is other")
    func other() {
        #expect(Reachability.connectionType(isSatisfied: true) == .other)
    }

    @Test("currentStatus returns one of the known cases")
    func currentStatusReturnsKnownCase() async {
        let status = await Reachability.currentStatus()
        let known: [Reachability.ConnectionType] = [
            .wifi, .cellular, .wired, .other, .unavailable
        ]
        #expect(known.contains(status))
    }
}
