import Foundation

public extension Thread {
    /// Best-effort name for `self`: `"main"` for the main thread, the thread's
    /// `name` if set, or its `description` as a fallback.
    var threadName: String {
        if self === Thread.main { return "main" }
        if let name, !name.isEmpty { return name }
        return description
    }

    /// Best-effort label of the dispatch queue or operation queue currently
    /// driving this thread. Returns `"n/a"` when neither is identifiable.
    var queueName: String {
        if let label = String(validatingCString: __dispatch_queue_get_label(nil)) {
            return label
        }
        if let opName = OperationQueue.current?.name, !opName.isEmpty {
            return opName
        }
        if let underlying = OperationQueue.current?.underlyingQueue?.label, !underlying.isEmpty {
            return underlying
        }
        return "n/a"
    }

    /// Logs the current thread + queue context via `Log.debug`. Debug aid only.
    static func printCurrent() {
        let queueLabel = OperationQueue.current?.underlyingQueue?.label ?? "<none>"
        Log.debug("⚡️ \(Thread.current) | 🏭 \(queueLabel)")
    }
}
