import Foundation

public extension DispatchQueue {
    private static let mainQueueMarker: DispatchSpecificKey<Void> = {
        let key = DispatchSpecificKey<Void>()
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()

    /// `true` when called from code currently dispatched on the main queue.
    /// Implemented via a one-time `DispatchSpecificKey` marker.
    static var isMainQueue: Bool {
        getSpecific(key: mainQueueMarker) != nil
    }

    /// `true` when called from code currently dispatched on `queue`. Uses a
    /// per-call `DispatchSpecificKey` so concurrent calls do not collide.
    /// Intended as a debug aid, not a synchronisation primitive.
    static func isCurrent(_ queue: DispatchQueue) -> Bool {
        let key = DispatchSpecificKey<Void>()
        queue.setSpecific(key: key, value: ())
        defer { queue.setSpecific(key: key, value: nil) }
        return DispatchQueue.getSpecific(key: key) != nil
    }

    /// Runs `work` synchronously when the receiver is the main queue and the
    /// caller is already on the main thread; otherwise dispatches asynchronously.
    /// Useful for bridging legacy callback APIs to UI updates.
    func safeAsync(_ work: @escaping @Sendable () -> Void) {
        if self === DispatchQueue.main && Thread.isMainThread {
            work()
        } else {
            async { work() }
        }
    }

    /// `@autoclosure` shorthand of ``safeAsync(_:)``.
    func safeAsync(execute work: @autoclosure @escaping @Sendable () -> Void) {
        safeAsync { work() }
    }

    /// `TimeInterval` convenience over `asyncAfter(deadline:)`.
    func asyncAfter(
        delay: TimeInterval,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        execute work: @escaping @Sendable () -> Void
    ) {
        asyncAfter(deadline: .now() + delay, qos: qos, flags: flags, execute: work)
    }

    /// Logs the current queue label and thread alongside `action` via
    /// `Log.debug`. Debug aid only.
    static func log(_ action: String) {
        let queueLabel = String(validatingCString: __dispatch_queue_get_label(nil)) ?? "<unknown>"
        Log.debug("\(action) | queue: \(queueLabel) | thread: \(Thread.current)")
    }

    /// Returns a closure that debounces calls to `action` by `delay` seconds.
    /// Each invocation bumps an internal token; only the deferred work whose
    /// token still matches the most recent invocation actually runs `action`.
    /// - Parameters:
    ///   - delay: How long to wait after the last call before firing.
    ///   - action: The work to perform once the burst settles.
    /// - Returns: A `@Sendable` trigger closure to call from any context.
    func debounce(
        delay: TimeInterval,
        action: @escaping @Sendable () -> Void
    ) -> @Sendable () -> Void {
        let state = DebounceState()
        return { [self] in
            let token = state.bumpToken()
            asyncAfter(delay: delay) {
                if state.matches(token: token) {
                    action()
                }
            }
        }
    }
}

private final class DebounceState: @unchecked Sendable {
    private let lock = NSLock()
    private var token: Int = 0

    func bumpToken() -> Int {
        lock.lock()
        defer { lock.unlock() }
        token += 1
        return token
    }

    func matches(token: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return self.token == token
    }
}
