import CoreLocation
import Foundation
import Testing
@testable import HomerFoundation

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

@Suite("Coordinate")
struct CoordinateTests {
    @Test("Direct initializer stores latitude and longitude")
    func directInit() {
        let coord = Coordinate(latitude: 41.015, longitude: 28.979)
        #expect(coord.latitude == 41.015)
        #expect(coord.longitude == 28.979)
    }

    @Test("CLLocationCoordinate2D bridge round-trips")
    func clBridge() {
        let cl = CLLocationCoordinate2D(latitude: 1.5, longitude: 2.5)
        let coord = Coordinate(cl)
        #expect(coord.latitude == 1.5)
        #expect(coord.longitude == 2.5)
        let roundTrip = coord.clCoordinate
        #expect(roundTrip.latitude == 1.5)
        #expect(roundTrip.longitude == 2.5)
    }

    @Test("Codable round-trips through JSON")
    func codableRoundTrip() throws {
        let original = Coordinate(latitude: 41.015, longitude: 28.979)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Coordinate.self, from: data)
        #expect(decoded == original)
    }
}

@Suite("LocationAuthorization")
struct LocationAuthorizationTests {
    @Test("Maps CLAuthorizationStatus values")
    func mapping() {
        #expect(LocationAuthorization(.authorizedAlways) == .authorizedAlways)
        #expect(LocationAuthorization(.denied) == .denied)
        #expect(LocationAuthorization(.restricted) == .restricted)
        #expect(LocationAuthorization(.notDetermined) == .notDetermined)
        #if !os(macOS)
        #expect(LocationAuthorization(.authorizedWhenInUse) == .authorizedWhenInUse)
        #endif
    }

    @Test("isAuthorized returns true only for authorized states")
    func isAuthorized() {
        #expect(LocationAuthorization.authorizedAlways.isAuthorized)
        #expect(LocationAuthorization.authorizedWhenInUse.isAuthorized)
        #expect(!LocationAuthorization.denied.isAuthorized)
        #expect(!LocationAuthorization.restricted.isAuthorized)
        #expect(!LocationAuthorization.notDetermined.isAuthorized)
        #expect(!LocationAuthorization.unknown.isAuthorized)
    }
}

@Suite("LocationAccuracy")
struct LocationAccuracyTests {
    @Test("Maps CLLocationAccuracy magic values")
    func mapping() {
        #expect(LocationAccuracy(kCLLocationAccuracyBestForNavigation) == .bestForNavigation)
        #expect(LocationAccuracy(kCLLocationAccuracyBest) == .best)
        #expect(LocationAccuracy(kCLLocationAccuracyNearestTenMeters) == .nearestTenMeters)
        #expect(LocationAccuracy(kCLLocationAccuracyHundredMeters) == .hundredMeters)
        #expect(LocationAccuracy(kCLLocationAccuracyKilometer) == .kilometer)
        #expect(LocationAccuracy(kCLLocationAccuracyThreeKilometers) == .threeKilometers)
        #expect(LocationAccuracy(5000) == .poor)
    }

    @Test("Maps intermediate accuracy values to the correct bucket")
    func bucketing() {
        #expect(LocationAccuracy(5) == .nearestTenMeters)
        #expect(LocationAccuracy(50) == .hundredMeters)
        #expect(LocationAccuracy(500) == .kilometer)
        #expect(LocationAccuracy(2500) == .threeKilometers)
    }

    @Test("clAccuracy round-trips named cases")
    func clAccuracyRoundTrip() {
        let cases: [LocationAccuracy] = [
            .bestForNavigation, .best, .nearestTenMeters,
            .hundredMeters, .kilometer, .threeKilometers
        ]
        for original in cases {
            #expect(LocationAccuracy(original.clAccuracy) == original)
        }
    }
}
