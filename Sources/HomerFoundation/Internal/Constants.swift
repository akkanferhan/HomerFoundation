import Foundation

/// Internal namespace for shared constants. Kept `internal` to avoid leaking
/// implementation details into the public API surface.
enum Constants {
    /// Dispatch queue and channel labels used by HomerFoundation services.
    enum Labels {
        /// Queue label used by ``Reachability``'s long-lived `NWPathMonitor`.
        static let reachabilityMonitor = "com.homer.foundation.reachability"
        /// Queue label used by ``Reachability/currentStatus()``'s one-shot probe.
        static let reachabilityOneShot = "com.homer.foundation.reachability.oneshot"
    }

    /// Default subsystem / category strings for the ``Log`` channel.
    enum Logging {
        /// Subsystem fallback used by ``Log/default`` when the host bundle has
        /// no `bundleIdentifier` (command-line tools, tests, …).
        static let defaultSubsystem = "HomerFoundation"
        /// Category used by ``Log/default``.
        static let defaultCategory = "default"
    }

    /// Numeric thresholds used by the location bucketing logic.
    enum Location {
        /// Metres reported back by ``LocationAccuracy/poor``'s ``LocationAccuracy/clAccuracy``.
        /// Anything beyond ``LocationAccuracy/threeKilometers`` collapses into this bucket.
        static let poorAccuracyMeters: Double = 5000
    }
}
