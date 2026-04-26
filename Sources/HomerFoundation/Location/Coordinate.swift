import CoreLocation

/// A latitude/longitude pair, decoupled from `CLLocationCoordinate2D` so it can
/// flow safely across actor boundaries (`Sendable` + `Hashable` + `Codable`).
public struct Coordinate: Sendable, Equatable, Hashable, Codable {
    /// Latitude in degrees. Positive values are north of the equator.
    public let latitude: Double
    /// Longitude in degrees. Positive values are east of the prime meridian.
    public let longitude: Double

    /// Creates a coordinate from raw latitude and longitude values.
    /// - Parameters:
    ///   - latitude: Degrees north of the equator (negative for southern hemisphere).
    ///   - longitude: Degrees east of the prime meridian (negative for western hemisphere).
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
