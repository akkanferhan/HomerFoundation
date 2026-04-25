import CoreLocation
import Foundation
import Observation

/// Observable, `@MainActor`-isolated location service.
///
/// Wraps `CLLocationManager` for authorization state and uses
/// `CLLocationUpdate.liveUpdates` for the actual coordinate stream. SwiftUI
/// can bind to ``authorization`` / ``lastLocation`` directly; UIKit code can
/// read the same properties on every event.
///
/// Typical use:
/// ```swift
/// let service = LocationService()
/// service.requestWhenInUseAuthorization()
/// for try await coord in service.liveUpdates() {
///     // …
/// }
/// ```
@Observable
@MainActor
public final class LocationService: NSObject {
    /// Latest known authorization, refreshed via the delegate.
    public private(set) var authorization: LocationAuthorization = .notDetermined
    /// Most recent coordinate yielded by ``liveUpdates(configuration:)``.
    public private(set) var lastLocation: Coordinate?
    /// Accuracy reported alongside ``lastLocation``.
    public private(set) var lastAccuracy: LocationAccuracy?

    @ObservationIgnored private let manager: CLLocationManager

    public override init() {
        let manager = CLLocationManager()
        self.manager = manager
        super.init()
        self.authorization = LocationAuthorization(manager.authorizationStatus)
        manager.delegate = self
    }

    /// Prompts the user for "When In Use" location access. Triggers the system
    /// permission alert the first time it's called.
    public func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    /// Prompts the user for "Always" access. Requires "When In Use" first.
    public func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    /// Geodesic distance from ``lastLocation`` to a target. Returns `nil` until
    /// the first live update has arrived.
    public func distance(from coordinate: Coordinate) -> CLLocationDistance? {
        lastLocation?.distance(to: coordinate)
    }

    /// Subscribes to live location updates. Each yielded ``Coordinate`` also
    /// updates ``lastLocation`` and ``lastAccuracy``. Cancelling the consuming
    /// task tears down the underlying `CLLocationUpdate` session.
    /// - Parameter configuration: A `CLLocationUpdate.LiveConfiguration` preset
    ///   such as `.default`, `.fitness`, or `.automotiveNavigation`.
    public func liveUpdates(
        configuration: CLLocationUpdate.LiveConfiguration = .default
    ) -> AsyncThrowingStream<Coordinate, Error> {
        AsyncThrowingStream { continuation in
            let task = Task { [weak self] in
                do {
                    for try await update in CLLocationUpdate.liveUpdates(configuration) {
                        guard let location = update.location else { continue }
                        let coord = Coordinate(location.coordinate)
                        let accuracy = LocationAccuracy(location.horizontalAccuracy)
                        self?.lastLocation = coord
                        self?.lastAccuracy = accuracy
                        continuation.yield(coord)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = LocationAuthorization(manager.authorizationStatus)
        Task { @MainActor [weak self] in
            self?.authorization = status
        }
    }
}
