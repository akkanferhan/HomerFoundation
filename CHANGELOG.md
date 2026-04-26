# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Result+Extensions` — `value`, `error`, `isSuccess`, `isFailure` accessors for terser conditional unwrapping.
- `Bundle+Extensions` — `appVersion`, `buildNumber`, `displayName` (with display → name → executable fallback), and `versionAndBuild`.
- `String.nilIfEmpty` and `String.trimmedOrNil` — pair with `??` to fall back to defaults for empty / whitespace-only input.
- `Date.isInPast`, `Date.isInFuture`, `Date.startOfDay(in:)`, `Date.isSameDay(as:in:)` — common calendar conveniences.
- `Coordinate` now conforms to `Codable` for storage / wire-format use cases.

### Changed

- Hard-coded queue labels, the `Log.default` subsystem fallback, and the
  `LocationAccuracy.poor` magic value were lifted into an internal `Constants`
  namespace so the dispatch and channel labels live next to each other.
- Filled in DocC comments for previously undocumented public symbols on
  `UserDefaultsValue`, `UserDefaultsCodableValue`, `PhoneNumberFormat.init`,
  `PhoneNumberFormatter.init`, `LocationService.init`, `Coordinate`, and the
  `AnyOptional` `Optional` conformance. Added explicit per-subscript docs
  (with trap warnings) on `String` / `Substring` integer subscripts.

## [0.1.0] — 2026-04-25

Initial release. Modern Swift 6 / iOS 18 rewrite of the legacy `FAFoundation` library, with strict concurrency, async/await, the `Observation` framework, Swift Testing, and DocC throughout.

### Added

- **Logging** — `Log`, a `Sendable` wrapper around `os.Logger` with default and scoped channels.
- **Storage** — `UserDefaultsValue` property wrapper for plist types (with a runtime guard against non-plist values) and `UserDefaultsCodableValue` for `URL`, `UUID`, and arbitrary `Codable` structs. Both accept an injectable `store`.
- **Reachability** — `@Observable @MainActor` wrapper around `NWPathMonitor`, plus a one-shot `Reachability.currentStatus()` async API. `ConnectionType` covers `.wifi`, `.cellular`, `.wired`, `.other`, `.unavailable`.
- **Location** — `LocationService` (`@Observable @MainActor`) backed by `CLLocationUpdate.liveUpdates`, with `Coordinate`, `LocationAccuracy`, and `LocationAuthorization` value types. `liveUpdates(configuration:)` accepts `CLLocationUpdate.LiveConfiguration` presets.
- **Components** — `PhoneNumberFormatter` with `PhoneNumberFormat` mask presets (`.international`, `.national`, `.compact`).
- **Protocols** — `AnyOptional`, `Describable`.
- **Extensions** — Foundation-friendly utilities for `Array`, `Collection`, `Comparable`, `Data`, `Date`, `Dictionary`, `DispatchQueue`, `Double`, `Encodable`, `Int`, `Optional`, `Sequence`, `String`/`Substring`, and `Thread`.
- **JSONError** — shared error type for the JSON serialization helpers.
- DocC documentation across the entire public API.

### Project conventions

- Error handling: `throws` for structural / serialization failures, `Optional` for parsing helpers, silent fallback for round-trip storage with a default value.
- No `FA` prefix — the module namespace handles disambiguation.
- Foundation/SwiftUI-first; UIKit-only utilities from the legacy library are intentionally not ported.

### Not included

- **Networking** is intentionally out of scope; it ships as a separate Swift package.
- Legacy `Constants`, manual observer pattern types, and `() -> ()` typealiases were dropped in favor of injectable stores, the `@Observable` macro, and raw closure types.

[Unreleased]: https://github.com/ferhanakkan/HomerFoundation/compare/0.1.0...HEAD
[0.1.0]: https://github.com/ferhanakkan/HomerFoundation/releases/tag/0.1.0
