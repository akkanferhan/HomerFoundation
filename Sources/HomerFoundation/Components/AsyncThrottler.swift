import Foundation

/// Structured-concurrency throttler: guarantees at most one execution
/// per interval, running the **first** call in a window immediately and
/// the **latest** superseded call at the window's end.
///
/// The complement to ``AsyncDebouncer``. Debouncing waits for a burst
/// to go quiet before acting — right for "stopped typing". Throttling
/// acts immediately and then rate-limits — right for streams that never
/// go quiet: scroll positions, location updates, progress reporting.
///
/// ```swift
/// let throttler = AsyncThrottler(interval: .seconds(2))
///
/// func locationDidUpdate(_ location: Coordinate) async {
///     await throttler.call { [weak self] in
///         await self?.uploadLocation(location)
///     }
/// }
/// ```
///
/// Behaviour per window: the first ``call(_:)`` runs its operation
/// immediately and opens an interval window. Calls arriving inside the
/// window replace each other; when the window closes, only the most
/// recent of them runs (leading + trailing-latest). A trailing run
/// opens a fresh window of its own, so a sustained burst settles into
/// one execution per interval.
///
/// `actor` isolation serialises scheduling, so the throttler can be
/// shared across concurrent callers without external locking.
public actor AsyncThrottler {
    private let interval: Duration
    private let clock = ContinuousClock()
    private var windowStart: ContinuousClock.Instant?
    private var pendingTrailing: Task<Void, Never>?

    /// Creates a throttler with the given minimum spacing between runs.
    /// - Parameter interval: Minimum time between two executions.
    public init(interval: Duration) {
        self.interval = interval
    }

    deinit {
        pendingTrailing?.cancel()
    }

    /// Runs `operation` immediately when outside the current window;
    /// otherwise schedules it for the window's end, replacing any
    /// operation a previous in-window call scheduled.
    /// - Parameter operation: The work to rate-limit.
    public func call(_ operation: @escaping @Sendable () async -> Void) {
        let now = clock.now
        if let windowStart, now < windowStart + interval {
            pendingTrailing?.cancel()
            let fireAt = windowStart + interval
            pendingTrailing = Task { [clock] in
                do {
                    try await clock.sleep(until: fireAt)
                } catch {
                    // Superseded by a newer in-window call (or cancelled).
                    return
                }
                await self.fireTrailing(operation)
            }
        } else {
            windowStart = now
            Task { await operation() }
        }
    }

    /// Cancels the trailing operation scheduled for the current window,
    /// if any. The next ``call(_:)`` after the window closes runs
    /// immediately as usual.
    public func cancel() {
        pendingTrailing?.cancel()
        pendingTrailing = nil
    }

    private func fireTrailing(_ operation: @escaping @Sendable () async -> Void) {
        // The trailing run opens its own window so sustained bursts
        // keep settling into one execution per interval.
        windowStart = clock.now
        pendingTrailing = nil
        Task { await operation() }
    }
}
