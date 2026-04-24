import Foundation
import os

/// A `Sendable` wrapper around `os.Logger` that exposes the standard log levels and
/// forwards through a default channel keyed off the host bundle identifier.
///
/// Use `Log.default` (or the `Log.<level>(_:)` static shortcuts) for app-wide
/// logging, or construct a `Log(subsystem:category:)` instance for a feature- or
/// module-specific channel.
public struct Log: Sendable {
    /// The underlying `os.Logger` used to emit messages.
    public let logger: os.Logger

    /// Creates a logger channel scoped to a subsystem and category.
    /// - Parameters:
    ///   - subsystem: A reverse-DNS identifier, typically your bundle id.
    ///   - category: A short label identifying the feature or module.
    public init(subsystem: String, category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }

    /// Default channel — uses `Bundle.main.bundleIdentifier` (or `"HomerFoundation"`)
    /// as the subsystem and `"default"` as the category.
    public static let `default` = Log(
        subsystem: Bundle.main.bundleIdentifier ?? "HomerFoundation",
        category: "default"
    )

    /// Logs a message at the `.debug` level.
    public func debug(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.debug("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }

    /// Logs a message at the `.info` level.
    public func info(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.info("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }

    /// Logs a message at the `.notice` level (the default level for `os.Logger`).
    public func notice(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.notice("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }

    /// Logs a message at the `.warning` level. Persisted to the unified log store.
    public func warning(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.warning("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }

    /// Logs a message at the `.error` level. Persisted and surfaced for diagnostics.
    public func error(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.error("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }

    /// Logs a message at the `.fault` level — for programmer errors and bugs.
    public func fault(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.fault("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }
}

public extension Log {
    /// Forwards to ``Log/default`` at the `.debug` level.
    static func debug(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.debug(message, file: file, line: line)
    }

    /// Forwards to ``Log/default`` at the `.info` level.
    static func info(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.info(message, file: file, line: line)
    }

    /// Forwards to ``Log/default`` at the `.notice` level.
    static func notice(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.notice(message, file: file, line: line)
    }

    /// Forwards to ``Log/default`` at the `.warning` level.
    static func warning(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.warning(message, file: file, line: line)
    }

    /// Forwards to ``Log/default`` at the `.error` level.
    static func error(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.error(message, file: file, line: line)
    }

    /// Forwards to ``Log/default`` at the `.fault` level.
    static func fault(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.fault(message, file: file, line: line)
    }
}
