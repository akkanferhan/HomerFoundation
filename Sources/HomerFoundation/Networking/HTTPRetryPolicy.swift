import Foundation

/// A small, transport-agnostic policy that decides **whether** to retry a
/// failed HTTP attempt and **how long** to wait before the next one.
///
/// `HTTPRetryPolicy` is a value type with no I/O of its own — callers are
/// expected to drive the loop themselves and consult the policy at the
/// retry decision points. The intent is that the same policy instance can
/// be shared across networking layers (e.g. a JSON client and an image
/// loader hitting the same rate-limited host) so backoff behaves
/// consistently and jitter actually decorrelates retries between callers.
///
/// ## Decision flow
/// On a non-2xx response or transport hiccup, the caller asks the policy:
/// 1. ``shouldRetry(statusCode:attempt:)`` — `false` means stop now and
///    propagate whatever error you would have thrown.
/// 2. ``delay(forAttempt:retryAfterHeader:)`` — sleep for this long, then
///    re-issue the request and bump the attempt counter.
///
/// ## Retry-After handling
/// When the server includes a `Retry-After` header, the value wins over
/// the policy's own backoff curve, but is clamped between
/// ``minDelay`` and ``maxDelay`` so a hostile or buggy server can't park
/// the caller for an hour. Both the RFC 7231 forms — `delay-seconds` and
/// `HTTP-date` — are recognised; anything else falls through to backoff.
///
/// ## Jitter
/// Backoff delays are perturbed by ``jitterFactor`` (uniformly random in
/// `[1 - factor, 1 + factor]`). Two clients seeing the same 429 burst
/// with the same policy will not retry in lockstep, which matters for
/// CloudFlare-style burst protections that punish synchronised clients.
public struct HTTPRetryPolicy: Sendable, Equatable {
    /// Maximum number of attempts, **including** the original one. A value
    /// of `3` means "one initial try + up to two retries".
    public let maxAttempts: Int

    /// Backoff seed. Attempt `n` waits roughly `baseDelay * 2^n` (before
    /// jitter) when no `Retry-After` header is present.
    public let baseDelay: TimeInterval

    /// Lower bound applied to every computed delay — including those
    /// derived from a `Retry-After` header. Prevents a server returning
    /// `Retry-After: 0` from turning the loop into a tight spin.
    public let minDelay: TimeInterval

    /// Upper bound applied to every computed delay — including those
    /// derived from a `Retry-After` header. Caps server-suggested waits
    /// so a hostile or misconfigured upstream can't park the caller
    /// indefinitely.
    public let maxDelay: TimeInterval

    /// Multiplicative jitter window. `0.3` produces delays uniformly in
    /// `[0.7 × delay, 1.3 × delay]`. Set to `0` to disable jitter
    /// (deterministic backoff, useful in tests).
    public let jitterFactor: Double

    /// Status codes the policy considers transiently retryable. Defaults
    /// to `408` (Request Timeout), `429` (Too Many Requests), and `503`
    /// (Service Unavailable); 5xx other than 503 are intentionally
    /// excluded — they typically indicate persistent server-side faults
    /// where blind retries amplify the outage.
    public let retryableStatuses: Set<Int>

    /// Creates a policy. Each parameter has a sensible default tuned for
    /// CloudFlare-fronted public APIs.
    /// - Parameters:
    ///   - maxAttempts: Total attempts including the first. Must be ≥ 1.
    ///   - baseDelay: Seed for exponential backoff. Default `0.8`.
    ///   - minDelay: Floor for any computed delay. Default `0.5`.
    ///   - maxDelay: Cap for any computed delay. Default `10`.
    ///   - jitterFactor: Multiplicative spread `[0, 1]`. Default `0.3`.
    ///   - retryableStatuses: Status codes treated as transient. Default
    ///     `{408, 429, 503}`.
    public init(
        maxAttempts: Int = Defaults.maxAttempts,
        baseDelay: TimeInterval = Defaults.baseDelay,
        minDelay: TimeInterval = Defaults.minDelay,
        maxDelay: TimeInterval = Defaults.maxDelay,
        jitterFactor: Double = Defaults.jitterFactor,
        retryableStatuses: Set<Int> = Defaults.retryableStatuses
    ) {
        self.maxAttempts = max(1, maxAttempts)
        self.baseDelay = baseDelay
        self.minDelay = minDelay
        self.maxDelay = maxDelay
        self.jitterFactor = max(0, min(1, jitterFactor))
        self.retryableStatuses = retryableStatuses
    }

    /// `true` when `statusCode` is in ``retryableStatuses`` and `attempt`
    /// hasn't yet reached ``maxAttempts``. `attempt` is **zero-indexed**
    /// — pass `0` for the original try, `1` for the first retry, etc.
    public func shouldRetry(statusCode: Int, attempt: Int) -> Bool {
        guard attempt < maxAttempts - 1 else { return false }
        return retryableStatuses.contains(statusCode)
    }

    /// Delay before the next attempt. Honours `Retry-After` when present
    /// and parseable; falls back to `baseDelay × 2^attempt` perturbed by
    /// jitter. Always clamped to `[minDelay, maxDelay]`.
    /// - Parameters:
    ///   - attempt: Zero-indexed counter of the attempt that just failed.
    ///   - retryAfterHeader: Raw `Retry-After` header value, if any.
    ///   - now: Reference instant used to resolve `HTTP-date` headers.
    ///     Injectable for deterministic tests; defaults to `Date()`.
    /// - Returns: Number of seconds to wait. Never negative.
    public func delay(
        forAttempt attempt: Int,
        retryAfterHeader: String? = nil,
        now: Date = Date()
    ) -> TimeInterval {
        if let header = retryAfterHeader,
           let parsed = Self.parseRetryAfter(header, now: now) {
            return clamp(parsed)
        }
        let exponential = baseDelay * pow(Defaults.exponentialBase, Double(attempt))
        let jittered = applyJitter(to: exponential)
        return clamp(jittered)
    }

    /// Parses a `Retry-After` header value. Returns the wait in seconds,
    /// or `nil` when neither RFC 7231 form (delay-seconds, HTTP-date) is
    /// recognised. A negative HTTP-date offset (a date in the past) is
    /// reported as `0`, leaving clamping to the caller.
    public static func parseRetryAfter(_ value: String, now: Date = Date()) -> TimeInterval? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if let seconds = TimeInterval(trimmed) {
            return max(0, seconds)
        }
        if let date = httpDateFormatter.date(from: trimmed) {
            return max(0, date.timeIntervalSince(now))
        }
        return nil
    }

    /// Convenience preset matching the default values, for sites that
    /// want an explicit handle rather than constructing a fresh value.
    public static let `default` = HTTPRetryPolicy()

    /// Public surface for the library-wide default values; exposed so
    /// callers can inherit individual fields when constructing a custom
    /// policy.
    public enum Defaults {
        public static let maxAttempts: Int = 3
        public static let baseDelay: TimeInterval = 0.8
        public static let minDelay: TimeInterval = 0.5
        public static let maxDelay: TimeInterval = 10
        public static let jitterFactor: Double = 0.3
        public static let retryableStatuses: Set<Int> = [408, 429, 503]
        static let exponentialBase: Double = 2
    }

    private func clamp(_ delay: TimeInterval) -> TimeInterval {
        min(max(delay, minDelay), maxDelay)
    }

    private func applyJitter(to delay: TimeInterval) -> TimeInterval {
        guard jitterFactor > 0 else { return delay }
        let lower = 1.0 - jitterFactor
        let upper = 1.0 + jitterFactor
        return delay * Double.random(in: lower...upper)
    }
}

/// `Retry-After` accepts two formats; we normalise both via
/// `DateFormatter` (`HTTP-date`) and `TimeInterval` (delay-seconds).
private let httpDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
    return formatter
}()
