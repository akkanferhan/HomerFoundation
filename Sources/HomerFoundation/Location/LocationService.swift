import CoreLocation
import Foundation
import Observation

@Observable
@MainActor
public final class LocationService: NSObject {
    public private(set) var authorization: LocationAuthorization = .notDetermined
    public private(set) var lastLocation: Coordinate?
    public private(set) var lastAccuracy: LocationAccuracy?

    @ObservationIgnored private let manager: CLLocationManager

    public override init() {
        let manager = CLLocationManager()
        self.manager = manager
        super.init()
        self.authorization = LocationAuthorization(manager.authorizationStatus)
        manager.delegate = self
    }

    public func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    public func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    public func distance(from coordinate: Coordinate) -> CLLocationDistance? {
        lastLocation?.distance(to: coordinate)
    }

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
