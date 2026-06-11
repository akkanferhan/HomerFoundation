import Foundation

/// Thrown by ``withTimeout(_:operation:)`` when the operation does not
/// finish within the limit.
public struct TimeoutError: Error, Equatable, CustomStringConvertible {
    /// The limit that was exceeded.
    public let limit: Duration

    /// Creates an error describing an exceeded `limit`.
    public init(limit: Duration) {
        self.limit = limit
    }

    public var description: String {
        "Operation timed out after \(limit)."
    }
}

/// Runs `operation` and fails with ``TimeoutError`` if it does not
/// finish within `limit`.
///
/// Bounds awaits on work that lacks a deadline of its own — actor
/// hand-offs, continuation bridges over callback APIs, third-party SDK
/// calls:
///
/// ```swift
/// let token = try await withTimeout(.seconds(5)) {
///     try await authProvider.refreshToken()
/// }
/// ```
///
/// The operation and a timer race in a task group; the loser is
/// cancelled. Cancellation is **cooperative**: a timed-out operation
/// stops promptly only if it (or the APIs it awaits) honours task
/// cancellation — a tight compute loop that never checks
/// `Task.isCancelled` keeps running in the background even though the
/// caller has already received ``TimeoutError``.
///
/// When the operation itself throws before the limit, its error
/// propagates unchanged.
/// - Parameters:
///   - limit: Maximum time the operation may take.
///   - operation: The work to bound.
/// - Returns: The operation's value when it beats the limit.
public func withTimeout<T: Sendable>(
    _ limit: Duration,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        group.addTask {
            try await Task.sleep(for: limit)
            throw TimeoutError(limit: limit)
        }
        // `next()` returns the first child to finish — the value when
        // the operation wins, or rethrows TimeoutError / the
        // operation's own error. Either way the loser is cancelled.
        guard let result = try await group.next() else {
            // Unreachable: the group always has two children.
            throw TimeoutError(limit: limit)
        }
        group.cancelAll()
        return result
    }
}
