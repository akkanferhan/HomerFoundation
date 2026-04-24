import Foundation

public extension Thread {
    var threadName: String {
        if self === Thread.main { return "main" }
        if let name, !name.isEmpty { return name }
        return description
    }

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

    static func printCurrent() {
        let queueLabel = OperationQueue.current?.underlyingQueue?.label ?? "<none>"
        Log.debug("⚡️ \(Thread.current) | 🏭 \(queueLabel)")
    }
}
