import Foundation
import Network
import Observation

/// Observable connectivity state, backed by `NWPathMonitor`.
///
/// `Reachability` is the production conformer of ``ReachabilityProviding``.
/// Create one instance per scope, call ``start()`` to begin observing, read
/// ``isConnected`` and ``connectionType`` from any view layer, and call
/// ``stop()`` to release the underlying monitor. For one-shot checks use
/// ``currentStatus()``; for SwiftUI previews and unit tests use
/// ``PreviewReachability``.
@Observable
@MainActor
public final class Reachability: ReachabilityProviding {
    /// Source-compatibility alias — ``ConnectionType`` was lifted to a
    /// top-level type in 0.5.0 so the ``ReachabilityProviding`` protocol can
    /// reference it without depending on this concrete conformer.
    public typealias ConnectionType = HomerFoundation.ConnectionType

    public private(set) var isConnected: Bool = false
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
