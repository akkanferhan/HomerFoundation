import Foundation
import Network
import Observation

@Observable
@MainActor
public final class Reachability {
    public enum ConnectionType: Sendable, Equatable {
        case wifi
        case cellular
        case wired
        case other
        case unavailable
    }

    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unavailable

    @ObservationIgnored private var monitor: NWPathMonitor?
    @ObservationIgnored private let queue = DispatchQueue(label: "com.homer.foundation.reachability", qos: .utility)

    public init() {}

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

    public func stop() {
        monitor?.cancel()
        monitor = nil
    }

    private func apply(isConnected: Bool, connectionType: ConnectionType) {
        self.isConnected = isConnected
        self.connectionType = connectionType
    }

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
}
