import Foundation
import Observation

/// The kind of network interface currently providing connectivity, plus a
/// dedicated case for "no usable path".
///
/// Lifted out of ``Reachability`` in 0.5.0 so the protocol-oriented API can
/// reference the value type without depending on a concrete conformer.
/// ``Reachability/ConnectionType`` remains as a typealias for source
/// compatibility.
public enum ConnectionType: Sendable, Equatable {
    case wifi
    case cellular
    case wired
    /// A satisfied path that does not advertise as Wi-Fi, cellular, or wired
    /// (loopback, VPN-only paths, etc.).
    case other
    /// No usable connection.
    case unavailable
}

/// Observable connectivity state, abstracted so consumers can depend on the
/// protocol and inject either the production ``Reachability`` (backed by
/// `NWPathMonitor`) or a stub like ``PreviewReachability``.
///
/// Conformers must also be `@Observable` so SwiftUI views and `@Bindable`
/// usages re-render when ``isConnected`` or ``connectionType`` change.
@MainActor
public protocol ReachabilityProviding: AnyObject, Observable {
    /// `true` when the system reports a satisfied network path.
    var isConnected: Bool { get }
    /// The active interface type, or ``ConnectionType/unavailable``.
    var connectionType: ConnectionType { get }

    /// Starts observing path updates. Implementations must be safe to call
    /// while already running (no-op).
    func start()
    /// Stops observing and releases any underlying resources. Subsequent
    /// ``start()`` calls must be able to resume observation.
    func stop()
}
