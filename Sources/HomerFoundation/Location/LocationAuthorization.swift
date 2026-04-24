import CoreLocation

public enum LocationAuthorization: Sendable, Equatable {
    case authorizedAlways
    case authorizedWhenInUse
    case denied
    case restricted
    case notDetermined
    case unknown

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

    public var isAuthorized: Bool {
        self == .authorizedAlways || self == .authorizedWhenInUse
    }
}
