import Foundation

public extension Bundle {
    /// The marketing version string, read from `CFBundleShortVersionString`.
    /// Returns `nil` when the key is missing — typical for SwiftPM test bundles
    /// and command-line targets.
    var appVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    /// The build number, read from `CFBundleVersion`. Returns `nil` when the
    /// key is missing.
    var buildNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }

    /// The user-facing app name. Falls back through `CFBundleDisplayName`,
    /// `CFBundleName`, and finally the bundle's executable name. Returns `nil`
    /// only when none of those keys are populated.
    var displayName: String? {
        if let name = infoDictionary?["CFBundleDisplayName"] as? String, !name.isEmpty {
            return name
        }
        if let name = infoDictionary?["CFBundleName"] as? String, !name.isEmpty {
            return name
        }
        return infoDictionary?["CFBundleExecutable"] as? String
    }

    /// `"<appVersion> (<buildNumber>)"` when both are present, otherwise whichever
    /// component is available. Useful for diagnostics screens and logs.
    var versionAndBuild: String? {
        switch (appVersion, buildNumber) {
        case let (version?, build?): "\(version) (\(build))"
        case let (version?, nil): version
        case let (nil, build?): build
        case (nil, nil): nil
        }
    }
}
