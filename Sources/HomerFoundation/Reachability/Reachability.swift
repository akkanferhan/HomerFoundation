import Foundation
import Network
import Observation

/// Observable connectivity state, backed by `NWPathMonitor`.
///
/// `Reachability` is a `@MainActor` `@Observable` class designed for SwiftUI and
/// UIKit. Create one instance per scope, call ``start()`` to begin observing,
/// read ``isConnected`` and ``connectionType`` from any view layer, and call
/// ``stop()`` to release the underlying monitor. For one-shot checks use
/// ``currentStatus()`` instead.
@Observable
@MainActor
public final class Reachability {
    /// The kind of network interface currently providing connectivity.
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

    /// `true` when the system reports a satisfied network path.
    public private(set) var isConnected: Bool = false
    /// The active interface type, or ``ConnectionType/unavailable``.
    public private(set) var connectionType: ConnectionType = .unavailable

    @ObservationIgnored private var monitor: NWPathMonitor?
    @ObservationIgnored private let queue = DispatchQueue(
        label: Constants.Labels.reachabilityMonitor,
        qos: .utility
    )

    public init() {}

    /// Starts observing path updates. No-op when already running.
    public func start() {
        guard monitor == nil else { return }
        let monitor = NWPathMonitor()
        self.monitor = monitor
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            let type = Reachability.connectionType(
                isSatisfied: connected,
                wifi: path.usesInterfaceType(.wifi),
                cellular: path.usesInterfaceType(.cellular),
                wired: path.usesInterfaceType(.wiredEthernet)
            )
            Task { @MainActor in
                self?.apply(isConnected: connected, connectionType: type)
            }
        }
        monitor.start(queue: queue)
    }

    /// Stops observing and releases the underlying monitor. Subsequent
    /// ``start()`` calls create a fresh monitor.
    public func stop() {
        monitor?.cancel()
        monitor = nil
    }

    private func apply(isConnected: Bool, connectionType: ConnectionType) {
        self.isConnected = isConnected
        self.connectionType = connectionType
    }

    /// Pure derivation from path status flags to ``ConnectionType``. Exposed
    /// internally so the table-driven test suite can exercise it without a
    /// real `NWPathMonitor`.
    nonisolated static func connectionType(
        isSatisfied: Bool,
        wifi: Bool = false,
        cellular: Bool = false,
        wired: Bool = false
    ) -> ConnectionType {
        guard isSatisfied else { return .unavailable }
        if wifi { return .wifi }
        if cellular { return .cellular }
        if wired { return .wired }
        return .other
    }

    /// Returns the device's current connection type by briefly observing a fresh
    /// `NWPathMonitor`. Use this for one-shot checks; for a long-lived observable
    /// state, create a `Reachability` instance and call ``start()``.
    public nonisolated static func currentStatus() async -> ConnectionType {
        await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: Constants.Labels.reachabilityOneShot)
            let once = OnceFlag()
            monitor.pathUpdateHandler = { path in
                guard once.fire() else { return }
                let type = connectionType(
                    isSatisfied: path.status == .satisfied,
                    wifi: path.usesInterfaceType(.wifi),
                    cellular: path.usesInterfaceType(.cellular),
                    wired: path.usesInterfaceType(.wiredEthernet)
                )
                monitor.cancel()
                continuation.resume(returning: type)
            }
            monitor.start(queue: queue)
        }
    }
}

private final class OnceFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var triggered = false

    func fire() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard !triggered else { return false }
        triggered = true
        return true
    }
}
