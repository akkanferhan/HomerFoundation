import Foundation
import Testing
@testable import HomerFoundation

@Suite("Bundle+Extensions")
struct BundleExtensionsTests {
    @Test("Smoke: helpers do not crash for the running test bundle")
    func smokeForTestBundle() {
        // SwiftPM test bundles typically lack version Info.plist keys. The
        // accessors must therefore return `nil` rather than trap, and
        // `versionAndBuild` should compose without error.
        let bundle = Bundle.main
        _ = bundle.appVersion
        _ = bundle.buildNumber
        _ = bundle.displayName
        _ = bundle.versionAndBuild
    }

    @Test("Smoke: helpers do not crash for `Bundle(for:)` of a test class")
    func smokeForClassBundle() {
        let bundle = Bundle(for: BundleExtensionsTestHook.self)
        _ = bundle.appVersion
        _ = bundle.buildNumber
        _ = bundle.displayName
        _ = bundle.versionAndBuild
    }

    @Test("appVersion reads CFBundleShortVersionString when an on-disk plist is present")
    func appVersionFromOnDiskBundle() throws {
        let bundle = try makeStubBundle(with: [
            "CFBundleShortVersionString": "1.2.3",
            "CFBundleVersion": "456",
            "CFBundleName": "Stub"
        ])
        #expect(bundle.appVersion == "1.2.3")
        #expect(bundle.buildNumber == "456")
        #expect(bundle.versionAndBuild == "1.2.3 (456)")
    }

    @Test("displayName falls back through display, name, executable")
    func displayNameFallback() throws {
        let displayBundle = try makeStubBundle(with: [
            "CFBundleDisplayName": "Pretty Name",
            "CFBundleName": "RawName",
            "CFBundleExecutable": "binary"
        ])
        #expect(displayBundle.displayName == "Pretty Name")

        let nameBundle = try makeStubBundle(with: [
            "CFBundleName": "RawName",
            "CFBundleExecutable": "binary"
        ])
        #expect(nameBundle.displayName == "RawName")

        let execBundle = try makeStubBundle(with: [
            "CFBundleExecutable": "binary"
        ])
        #expect(execBundle.displayName == "binary")

        let emptyBundle = try makeStubBundle(with: [:])
        #expect(emptyBundle.displayName == nil)
    }

    @Test("displayName ignores empty display/name strings")
    func displayNameIgnoresEmpty() throws {
        let bundle = try makeStubBundle(with: [
            "CFBundleDisplayName": "",
            "CFBundleName": "",
            "CFBundleExecutable": "binary"
        ])
        #expect(bundle.displayName == "binary")
    }

    @Test("versionAndBuild handles missing components")
    func versionAndBuildPartial() throws {
        let onlyVersion = try makeStubBundle(with: ["CFBundleShortVersionString": "9.9"])
        #expect(onlyVersion.versionAndBuild == "9.9")

        let onlyBuild = try makeStubBundle(with: ["CFBundleVersion": "100"])
        #expect(onlyBuild.versionAndBuild == "100")

        let neither = try makeStubBundle(with: [:])
        #expect(neither.versionAndBuild == nil)
    }

    // MARK: Helpers

    /// Materialises a real on-disk bundle directory containing the given
    /// `Info.plist` keys, then loads it via `Bundle(url:)`. This is the only
    /// way to exercise the real `infoDictionary` lookup since `Bundle` reads
    /// from disk on first access and refuses to honour overridden subclass
    /// methods through `Bundle(for:)`.
    private func makeStubBundle(with info: [String: Any]) throws -> Bundle {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HomerFoundationTests")
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let plistURL = directory.appendingPathComponent("Info.plist")
        let plistData = try PropertyListSerialization.data(
            fromPropertyList: info,
            format: .xml,
            options: 0
        )
        try plistData.write(to: plistURL)
        guard let bundle = Bundle(url: directory) else {
            throw BundleStubError.couldNotLoad
        }
        return bundle
    }
}

// MARK: - Helpers

private enum BundleStubError: Error {
    case couldNotLoad
}

private final class BundleExtensionsTestHook {}
