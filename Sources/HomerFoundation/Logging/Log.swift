import Foundation
import os

public struct Log: Sendable {
    public let logger: os.Logger

    public init(subsystem: String, category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }

    public static let `default` = Log(
        subsystem: Bundle.main.bundleIdentifier ?? "HomerFoundation",
        category: "default"
    )

    public func debug(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.debug("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }

    public func info(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.info("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }

    public func notice(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.notice("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }

    public func warning(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.warning("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }

    public func error(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.error("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }

    public func fault(_ message: String, file: String = #fileID, line: Int = #line) {
        logger.fault("[\(file, privacy: .public):\(line, privacy: .public)] \(message, privacy: .public)")
    }
}

public extension Log {
    static func debug(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.debug(message, file: file, line: line)
    }

    static func info(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.info(message, file: file, line: line)
    }

    static func notice(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.notice(message, file: file, line: line)
    }

    static func warning(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.warning(message, file: file, line: line)
    }

    static func error(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.error(message, file: file, line: line)
    }

    static func fault(_ message: String, file: String = #fileID, line: Int = #line) {
        Log.default.fault(message, file: file, line: line)
    }
}
