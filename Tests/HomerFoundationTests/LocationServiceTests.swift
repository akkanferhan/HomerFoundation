import Testing
import CoreLocation
@testable import HomerFoundation

@Suite("LocationService")
@MainActor
struct LocationServiceTests {
    @Test("Initial state has nil location and accuracy")
    func initialState() {
        let service = LocationService()
        #expect(service.lastLocation == nil)
        #expect(service.lastAccuracy == nil)
    }

    @Test("Authorization starts as one of the documented cases")
    func initialAuthorization() {
        let service = LocationService()
        let valid: [LocationAuthorization] = [
            .notDetermined, .denied, .restricted,
            .authorizedAlways, .authorizedWhenInUse, .unknown
        ]
        #expect(valid.contains(service.authorization))
    }

    @Test("Authorization requests do not crash")
    func smokeAPI() {
        let service = LocationService()
        service.requestWhenInUseAuthorization()
        service.requestAlwaysAuthorization()
    }

    @Test("liveUpdates returns a stream that can be cancelled immediately")
    func liveUpdatesCancellable() async {
        let service = LocationService()
        let stream = service.liveUpdates()
        let task = Task {
            for try await _ in stream {
                break
            }
        }
        task.cancel()
        _ = await task.result
    }

    @Test("distance returns nil when no last location")
    func distanceNilWithoutLastLocation() {
        let service = LocationService()
        let target = Coordinate(latitude: 41.0, longitude: 28.9)
        #expect(service.distance(from: target) == nil)
    }
}

@Suite("Coordinate.distance")
struct CoordinateDistanceTests {
    @Test("distance to self is zero")
    func distanceToSelf() {
        let a = Coordinate(latitude: 41.015137, longitude: 28.979530)
        #expect(a.distance(to: a) == 0)
    }

    @Test("distance is symmetric and roughly matches expected meters")
    func distanceBetweenLandmarks() {
        let istanbul = Coordinate(latitude: 41.015137, longitude: 28.979530)
        let ankara = Coordinate(latitude: 39.933365, longitude: 32.859741)
        let forward = istanbul.distance(to: ankara)
        let backward = ankara.distance(to: istanbul)
        #expect(abs(forward - backward) < 1)
        #expect(forward > 300_000 && forward < 400_000)
    }
}
