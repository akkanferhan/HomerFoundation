import CoreLocation

/// The user's location authorization, mapped from `CLAuthorizationStatus` into a
/// `Sendable` enum that crucially does **not** trap on future unknown cases.
public enum LocationAuthorization: Sendable, Equatable {
    case authorizedAlways
    case authorizedWhenInUse
    case denied
    case restricted
    case notDetermined
    /// A future `CLAuthorizationStatus` case the SDK does not yet know about.
    case unknown

    /// Bridges from `CLAuthorizationStatus`. Unknown future cases collapse to
    /// ``unknown`` rather than crashing.
    public init(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways: self = .authorizedAlways
        case .authorizedWhenInUse: self = .authorizedWhenInUse
        case .denied: self = .denied
        case .restricted: self = .restricted
        case .notDetermined: self = .notDetermined
        @unknown default: self = .unknown
        }
    }

    /// `true` when the app may currently access location data.
    public var isAuthorized: Bool {
        self == .authorizedAlways || self == .authorizedWhenInUse
    }
}
