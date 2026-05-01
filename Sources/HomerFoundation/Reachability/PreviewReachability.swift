import Foundation
import Observation

/// Mutable, observation-friendly stub conforming to ``ReachabilityProviding``.
///
/// Drive ``isConnected`` and ``connectionType`` directly from SwiftUI previews
/// or unit tests instead of standing up a real `NWPathMonitor`. ``start()`` and
/// ``stop()`` are no-ops; the test/preview owns the state transitions.
///
/// ```swift
/// // SwiftUI preview
/// #Preview("Offline") {
///     ContentView(reachability: PreviewReachability(isConnected: false))
/// }
///
/// // Unit test
/// let stub = PreviewReachability(isConnected: true, connectionType: .wifi)
/// stub.connectionType = .cellular  // simulate a transition
/// ```
@Observable
@MainActor
public final class PreviewReachability: ReachabilityProviding {
    public var isConnected: Bool
    public var connectionType: ConnectionType

    public init(
        isConnected: Bool = true,
        connectionType: ConnectionType = .wifi
    ) {
        self.isConnected = isConnected
        self.connectionType = connectionType
    }

    public func start() {}
    public func stop() {}
}
