import Foundation

/// Closure with no input and no output. Common shorthand for completion handlers
/// that only signal "done."
public typealias VoidCompletion = () -> Void

/// Closure that delivers a single value of type `T` and returns nothing. Common
/// shorthand for callback-style result delivery.
public typealias ValueCompletion<T> = (T) -> Void

/// Loosely-typed key/value bag used for ad-hoc parameter dictionaries
/// (e.g. analytics events, untyped JSON bodies). Prefer a concrete `Codable`
/// type when the schema is known.
public typealias Parameters = [String: Any]
