import CoreLocation

/// Bucketed view of `CLLocationAccuracy` magic values.
public enum LocationAccuracy: Sendable, Equatable {
    case bestForNavigation
    case best
    case nearestTenMeters
    case hundredMeters
    case kilometer
    case threeKilometers
    /// Anything coarser than three kilometres.
    case poor

    /// Maps a raw `CLLocationAccuracy` (in metres, with negative magic values
    /// for `bestForNavigation` / `best`) into the closest bucket.
    public init(_ accuracy: CLLocationAccuracy) {
        switch accuracy {
        case ...(-2): self = .bestForNavigation
        case ...(-1): self = .best
        case ...10: self = .nearestTenMeters
        case ...100: self = .hundredMeters
        case ...1000: self = .kilometer
        case ...3000: self = .threeKilometers
        default: self = .poor
        }
    }

    /// Round-trip back to `CLLocationAccuracy`. ``poor`` returns 5000m.
    public var clAccuracy: CLLocationAccuracy {
        switch self {
        case .bestForNavigation: kCLLocationAccuracyBestForNavigation
        case .best: kCLLocationAccuracyBest
        case .nearestTenMeters: kCLLocationAccuracyNearestTenMeters
        case .hundredMeters: kCLLocationAccuracyHundredMeters
        case .kilometer: kCLLocationAccuracyKilometer
        case .threeKilometers: kCLLocationAccuracyThreeKilometers
        case .poor: 5000
        }
    }
}
