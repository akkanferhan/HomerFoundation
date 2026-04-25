import CoreLocation

/// A latitude/longitude pair, decoupled from `CLLocationCoordinate2D` so it can
/// flow safely across actor boundaries (`Sendable` + `Hashable`).
public struct Coordinate: Sendable, Equatable, Hashable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /// Bridges from a `CLLocationCoordinate2D`.
    public init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    /// Bridges back to `CLLocationCoordinate2D` for MapKit / CoreLocation calls.
    public var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Geodesic distance in metres to another coordinate, computed via
    /// `CLLocation.distance(from:)`.
    public func distance(to other: Coordinate) -> CLLocationDistance {
        let lhs = CLLocation(latitude: latitude, longitude: longitude)
        let rhs = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return lhs.distance(from: rhs)
    }
}
