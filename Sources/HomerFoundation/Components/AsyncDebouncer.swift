import Foundation

/// Structured-concurrency debouncer: collapses bursts of calls into a
/// single execution of the **latest** operation after a quiet interval.
///
/// The async counterpart to ``Dispatch/DispatchQueue/debounce(delay:queue:action:)``
/// for call sites that already live in Swift concurrency — typically
/// search-as-you-type, autosave, or remote validation triggered from
/// `@Observable` view models:
///
/// ```swift
/// let debouncer = AsyncDebouncer(interval: .milliseconds(300))
///
/// func queryChanged(_ text: String) async {
///     await debouncer.call { [weak self] in
///         await self?.performSearch(text)
///     }
/// }
/// ```
///
/// Each ``call(_:)`` cancels the previously scheduled-but-not-yet-run
/// operation, so only the operation from the final call in a burst
/// executes. An operation that has already **started** running is not
/// interrupted — cancellation only prevents pending ones from starting.
///
/// `actor` isolation serialises scheduling, so the debouncer can be
/// shared across concurrent callers without external locking.
public actor AsyncDebouncer {
    private let interval: Duration
    private var pending: Task<Void, Never>?

    /// Creates a debouncer with the given quiet interval.
    /// - Parameter interval: How long the burst must stay quiet before
    ///   the most recent operation runs.
    public init(interval: Duration) {
        self.interval = interval
    }

    deinit {
        pending?.cancel()
    }

    /// Schedules `operation` to run after the quiet interval, cancelling
    /// any operation scheduled by a previous call that has not started
    /// yet.
    /// - Parameter operation: The work to perform once the burst settles.
    public func call(_ operation: @escaping @Sendable () async -> Void) {
        pending?.cancel()
        pending = Task { [interval] in
            do {
                try await Task.sleep(for: interval)
            } catch {
                // Superseded by a newer call (or cancelled) — drop silently.
                return
            }
            await operation()
        }
    }

    /// Cancels the pending operation, if any, without scheduling a new
    /// one. Operations that already started are not interrupted.
    public func cancel() {
        pending?.cancel()
        pending = nil
    }
}
