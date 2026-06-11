# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **`AsyncThrottler`** — the complement to `AsyncDebouncer`: guarantees
  at most one execution per interval for streams that never go quiet
  (scroll positions, location updates, progress reporting). Runs the
  first call in a window immediately and the latest superseded call at
  the window's end (leading + trailing-latest); a trailing run opens a
  fresh window, so sustained bursts settle into one execution per
  interval. `cancel()` drops the pending trailing run.
- **`Sequence` concurrency helpers** — `asyncMap`, `asyncCompactMap`,
  and `asyncForEach` (serial, order-preserving, error-stopping), plus
  `concurrentMap` (task-group fan-out for independent I/O-bound work
  that preserves input order and cancels remaining work on the first
  error).
- **Keychain storage family** — the secure sibling of the
  `UserDefaults` wrappers:
  - `KeychainStoring` — protocol abstraction over a secure key/value
    store (`data(forKey:)` / `set` / `removeData`, plus UTF-8 `String`
    conveniences), following the same inject-a-stub pattern as
    `ReachabilityProviding`.
  - `Keychain` — Security-framework conformer storing
    generic-password items scoped by service (defaults to the bundle
    identifier), with optional access group and a `Sendable`
    `KeychainAccessibility` enum wrapping `kSecAttrAccessible*`.
    Update-first writes so token refresh doesn't trip
    `errSecDuplicateItem`.
  - `InMemoryKeychain` — lock-guarded dictionary stub for tests and
    previews; no entitlements, no residue.
  - `@KeychainCodableValue` — property wrapper persisting any
    `Codable` through `JSONEncoder`, mirroring
    `UserDefaultsCodableValue`'s forgiving contract (default on
    missing/corrupt, `nil` assignment removes, injectable store), with
    an optional-shorthand init.

- **`AsyncDebouncer`** — structured-concurrency debouncer `actor`, the
  async counterpart to `DispatchQueue.debounce` for `@Observable` view
  models (search-as-you-type, autosave). Each `call(_:)` cancels the
  previously scheduled-but-not-yet-run operation, so only the latest
  operation in a burst executes after the quiet interval; `cancel()`
  drops the pending one without scheduling.
- **`Collection.chunked(into:)`** — consecutive fixed-size chunks with a
  shorter tail. Sizes below `1` clamp to `1` rather than trapping, so no
  element is ever dropped.
- **`URL.appendingQueryItems(_:)`** (array and sorted-dictionary
  overloads) and **`URL.queryValue(for:)`** — query composition and
  lookup that preserve the existing query and percent-encoding via
  `URLComponents`.
- **`TimeInterval.seconds/minutes/hours/days(_:)`** — unit factories so
  call sites like `asyncAfter(delay: .minutes(5))` read in units instead
  of bare second counts.
- **`Date.isToday/isYesterday/isTomorrow(in:)`** and
  **`Date.adding(_:_:in:)`** — calendar-aware day classification and
  component arithmetic (DST-, month-length-, and leap-year-correct).
- **`String.digitsOnly`** — keeps only ASCII `0`–`9`; the usual pre-clean
  for phone, OTP, and card-number input. Pairs with `PhoneNumberFormatter`.
- **`Encodable.asJSONString(encoder:)`** and **`Data.decoded(as:decoder:)`**
  — complete the JSON bridge family alongside `asDictionary(encoder:)`,
  `Data.asJSONDictionary()`, and `Dictionary.asJSONString()`.

### Fixed

- `Encodable.asDictionary(encoder:)` now throws ``JSONError/notADictionary``
  when the encoded value is not a JSON object, as its doc comment always
  promised. It previously threw `EncodingError.invalidValue`, which broke
  error-handling consistency with `Data.asJSONDictionary()` — callers can
  now catch `JSONError` uniformly across the library's JSON helpers.

## [0.5.0] — 2026-05-01

### Added

- `ReachabilityProviding` — protocol abstraction over the connectivity API.
  Conformers expose `isConnected`, `connectionType`, `start()`, and `stop()`,
  and must be `@Observable` so SwiftUI views and `@Bindable` continue to
  re-render on state changes. Lets consumers depend on the protocol and
  inject either the real ``Reachability`` or a stub.
- `PreviewReachability` — mutable, observation-friendly stub conforming to
  `ReachabilityProviding`. `start()` / `stop()` are no-ops; tests and SwiftUI
  previews drive `isConnected` / `connectionType` directly to simulate
  transitions without touching `NWPathMonitor`.

### Changed

- `Reachability.ConnectionType` was lifted to a top-level `ConnectionType`
  enum so the new protocol can reference it without depending on the
  concrete conformer. A typealias inside `Reachability` keeps the old
  `Reachability.ConnectionType` spelling working — existing call sites
  compile unchanged.
- `Reachability` now formally conforms to `ReachabilityProviding`. Its
  storage, behaviour, and `currentStatus()` API are unchanged.

### Migration

- No required changes. To opt into protocol-based DI, switch consumer
  signatures from `Reachability` to `any ReachabilityProviding` (or a
  generic `R: ReachabilityProviding`) and inject `PreviewReachability` in
  previews / tests.

## [0.4.0] — 2026-04-29

### Added

- `HTTPRetryPolicy` — transport-agnostic retry policy for HTTP error
  handling. Retries on 408 / 429 / 503 with exponential backoff, honouring
  `Retry-After` (delta-seconds and HTTP-date forms) and capped attempt
  counts. Designed to drop into HomerNetwork or any URLSession-based
  client without coupling to a specific transport type.

## [0.3.0] — 2026-04-27

### Added

- `Array.subscript(safe:)` — bounds-checked element access. Returns `nil` for
  indices outside the array's `indices` (including negative values), avoiding
  the trap of the regular subscript on out-of-range access.

### Removed

- **BREAKING**: `HomerFoundation.version` literal. Consumers should derive the
  version from `Bundle` or `Package.resolved` instead. Aligns with the same
  cleanup applied to HomerImagery in its 0.1.0 candidate.

### Changed

- `Date+Extensions` reordered: `isInPast` and `isInFuture` now sit alongside
  `millisecondsSince1970` so all time-relative properties are grouped above
  formatting helpers. No semantic change.

### Tests

- Test target reorganized into folders mirroring `Sources/HomerFoundation`
  (`Extensions/`, `Components/`, `Location/`, `Logging/`, `Reachability/`,
  `Storage/`, `Protocols/`, `Typealiases/`). 26 test files restored from a
  short-lived single-file consolidation; helper types moved back into the
  suites that use them.
- Five new `@Test`s cover `Array.subscript(safe:)` (valid index, out-of-bounds,
  negative, empty array, single-element).

### Migration

- If consumer code referenced `HomerFoundation.version`, replace with
  `Bundle.main.appVersion` (provided by HomerFoundation 0.2.0+).

## [0.2.0] — 2026-04-26

### Added

- `VoidCompletion`, `ValueCompletion<T>`, `Parameters` — canonical closure and parameter-bag typealiases shared across the Homer suite. `VoidCompletion` = `() -> Void`; `ValueCompletion<T>` = `(T) -> Void`; `Parameters` = `[String: Any]` for untyped key/value bags.
- `String.asDouble` — parses the string as a `Double` via `Double.init(_:)`; returns `nil` for non-numeric input.
- `String.asURL` — guarded `URL(string:)` helper; returns `nil` for strings that are not valid URLs.
- `Data.append(_:encoding:)` — `@discardableResult mutating` convenience to append a `String` with a chosen `String.Encoding` (defaults to `.utf8`). Returns `false` and leaves the receiver untouched when the string cannot be encoded.
- `Double.zeroOmitted(decimals:)` — formats the value with up to `decimals` fractional digits (default `1`), dropping the fraction entirely when the value is a whole number. Output uses `.` as decimal separator (locale-independent).
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

[Unreleased]: https://github.com/akkanferhan/HomerFoundation/compare/0.5.0...HEAD
[0.5.0]: https://github.com/akkanferhan/HomerFoundation/releases/tag/0.5.0
[0.4.0]: https://github.com/akkanferhan/HomerFoundation/releases/tag/0.4.0
[0.3.0]: https://github.com/akkanferhan/HomerFoundation/releases/tag/0.3.0
[0.2.0]: https://github.com/akkanferhan/HomerFoundation/releases/tag/0.2.0
[0.1.0]: https://github.com/akkanferhan/HomerFoundation/releases/tag/0.1.0
