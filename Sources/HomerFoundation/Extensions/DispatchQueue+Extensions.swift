import Foundation

public extension DispatchQueue {
    private nonisolated(unsafe) static let mainQueueMarker: DispatchSpecificKey<Void> = {
        let key = DispatchSpecificKey<Void>()
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()

    static var isMainQueue: Bool {
        getSpecific(key: mainQueueMarker) != nil
    }

    static func isCurrent(_ queue: DispatchQueue) -> Bool {
        let key = DispatchSpecificKey<Void>()
        queue.setSpecific(key: key, value: ())
        defer { queue.setSpecific(key: key, value: nil) }
        return DispatchQueue.getSpecific(key: key) != nil
    }

    func safeAsync(_ work: @escaping @Sendable () -> Void) {
        if self === DispatchQueue.main && Thread.isMainThread {
            work()
        } else {
            async { work() }
        }
    }

    func safeAsync(execute work: @autoclosure @escaping @Sendable () -> Void) {
        safeAsync { work() }
    }

    func asyncAfter(
        delay: TimeInterval,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        execute work: @escaping @Sendable () -> Void
    ) {
        asyncAfter(deadline: .now() + delay, qos: qos, flags: flags, execute: work)
    }

    static func log(_ action: String) {
        let queueLabel = String(validatingCString: __dispatch_queue_get_label(nil)) ?? "<unknown>"
        Log.debug("\(action) | queue: \(queueLabel) | thread: \(Thread.current)")
    }

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
