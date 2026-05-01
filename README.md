# HomerFoundation

Modern Swift 6 / iOS 18 foundation library for the Homer suite of Apple apps. A consolidated set of extensions, value types, property wrappers, and small services that previously lived as copy-pasted snippets across projects.

- **Swift tools:** 6.0 (`swiftLanguageModes: [.v6]`, strict concurrency)
- **Platforms:** iOS 18+, macOS 14+
- **Tests:** Swift Testing
- **Status:** `0.5.0` — public API documented with DocC, 0 warnings

## Installation

Swift Package Manager — add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ferhanakkan/HomerFoundation.git", from: "0.5.0")
]
```

Then attach to a target:

```swift
.target(
    name: "MyApp",
    dependencies: ["HomerFoundation"]
)
```

In code:

```swift
import HomerFoundation
```

## Modules

### Logging — `Log`

A `Sendable` wrapper around `os.Logger`. Use the static shortcuts for app-wide logging or build a scoped channel.

```swift
Log.info("user signed in")
Log.error("payment failed: \(error)")

let auth = Log(subsystem: "com.example.app", category: "auth")
auth.debug("token refreshed")
```

### Storage — `UserDefaultsValue` / `UserDefaultsCodableValue`

Property wrappers over `UserDefaults`. Use `UserDefaultsValue` for plist types (`String`, `Int`, `Double`, `Bool`, `Date`, `Data`, arrays/dictionaries of those). Use `UserDefaultsCodableValue` for `URL`, `UUID`, or any `Codable` struct.

```swift
enum Settings {
    @UserDefaultsValue(key: "hasOnboarded") static var hasOnboarded = false
    @UserDefaultsValue(key: "lastSyncedAt") static var lastSyncedAt: Date?

    @UserDefaultsCodableValue(key: "profile") static var profile: Profile?
}
```

Both wrappers accept an injectable `store: UserDefaults` for tests and app groups.

### Reachability — `ReachabilityProviding`, `Reachability`, `PreviewReachability`

`@Observable @MainActor` connectivity state, abstracted behind the
`ReachabilityProviding` protocol so consumers can depend on the contract and
inject either the production `Reachability` (backed by `NWPathMonitor`) or
the in-memory `PreviewReachability` stub.

```swift
@State private var reachability = Reachability()

var body: some View {
    Text(reachability.isConnected ? "online" : "offline")
        .task { reachability.start() }
}

// One-shot:
let type = await Reachability.currentStatus()
```

Inject the protocol when you want testable / previewable views:

```swift
struct StatusView<R: ReachabilityProviding>: View {
    @Bindable var reachability: R
    var body: some View {
        Text(reachability.isConnected ? "online" : "offline")
    }
}

#Preview("Offline") {
    StatusView(reachability: PreviewReachability(isConnected: false, connectionType: .unavailable))
}
```

`ConnectionType` covers `.wifi`, `.cellular`, `.wired`, `.other`,
`.unavailable`. `Reachability.ConnectionType` remains as a typealias so
existing code compiles unchanged.

### Location — `LocationService`, `Coordinate`, `LocationAccuracy`, `LocationAuthorization`

`@Observable @MainActor` wrapper around `CLLocationManager` for authorization plus `CLLocationUpdate.liveUpdates` for the coordinate stream.

```swift
let service = LocationService()
service.requestWhenInUseAuthorization()

for try await coord in service.liveUpdates() {
    print(coord.latitude, coord.longitude)
}
```

`liveUpdates(configuration:)` accepts presets like `.default`, `.fitness`, or `.automotiveNavigation`. `Coordinate` is a `Sendable` value type with `distance(to:)`.

### Components — `PhoneNumberFormatter`

`#`-driven phone-number masks, with built-in international/national/compact presets.

```swift
let formatter = PhoneNumberFormatter(format: .international)
formatter.format("905551234567") // "+90 (555) 123-4567"
```

### Protocols — `AnyOptional`, `Describable`

`AnyOptional` powers nil-handling utilities (used by `UserDefaultsValue`). `Describable` provides a default `description` derived from the type's runtime metadata.

### Extensions

Foundation-friendly utilities — all `Sendable`-clean and DocC-documented.

| Type | Highlights |
|---|---|
| `Array` | `safe` subscript |
| `Bundle` | `appVersion`, `buildNumber`, `displayName`, `versionAndBuild` |
| `Collection` | `isNotEmpty` |
| `Comparable` | `clamped(to:)` |
| `Data` | `asJSONDictionary()`, `append(_:encoding:)` |
| `Date` | `millisecondsSince1970`, `string(withFormat:locale:timeZone:)`, `isInPast`, `isInFuture`, `startOfDay(in:)`, `isSameDay(as:in:)` |
| `Dictionary<String, Any>` | `asJSONString()` |
| `DispatchQueue` | `safeAsync { … }` (re-entrant main hop), `debounce`, `isMainQueue` |
| `Double` | `asInt`, `asCGFloat`, `asFloat`, `asString`, `rounded(toPlaces:)`, `zeroOmitted(decimals:)` |
| `Encodable` | `asDictionary(encoder:)` |
| `Int` | `asCGFloat`, `asFloat`, `asDouble`, `asString` |
| `Optional` | `orEmpty`, `orZero`, `orFalse`, `isNilOrEmpty`, `isNotNilOrEmpty` |
| `Result` | `value`, `error`, `isSuccess`, `isFailure` |
| `Sequence` | `uniqued()`, `uniqued(on:)` |
| `String` / `Substring` | `isValidEmail`, `parsedWords`, `wordCount`, `asISO8601Date`, `asDate(format:)`, `asDouble`, `asURL`, `whitespaceTrimmed`, `removingWhitespaces`, `nilIfEmpty`, `trimmedOrNil`, `withTurkishTransliteration`, integer subscript |
| `Thread` | `threadName`, `queueName`, `printCurrent()` |
| `JSONError` | shared error type for the JSON helpers |

The error-handling convention across the library:

| Situation | Pattern |
|---|---|
| Structural / serialization failures | `throws` |
| Parsing (`Int(string)`, `String.asISO8601Date`) | `Optional` |
| Round-trip storage with default value | Silent fallback (`UserDefaultsValue`) |

## Out of scope

- **Networking** — built as a separate Swift package.
- **UIKit-only utilities** — the legacy `FAFoundation` shipped a handful of `NSAttributedString` and `UIFont` helpers; HomerFoundation is Foundation/SwiftUI-first.

## Development

```bash
swift build
swift test
```

Tests are written with [Swift Testing](https://developer.apple.com/xcode/swift-testing/). CI (GitHub Actions) runs `swift test` on every push and PR.

## License

[MIT](LICENSE) © 2026 Ferhan Akkan
