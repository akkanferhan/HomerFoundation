/// Erases the wrapped type of an `Optional` so callers can ask `isNil` without
/// committing to a concrete `Wrapped`. Useful inside generic property wrappers
/// that need to detect a `nil` payload without reflection.
public protocol AnyOptional {
    /// `true` when the optional is `.none`.
    var isNil: Bool { get }
    /// `true` when the optional is `.some`.
    var isNotNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
    public var isNotNil: Bool { self != nil }
}
