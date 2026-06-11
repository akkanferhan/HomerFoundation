import Foundation

public extension Sequence {
    /// `map` with an `async` transform, applied **serially** in
    /// sequence order. Rethrows the first error and stops.
    /// - Parameter transform: The async mapping applied to each element.
    /// - Returns: The transformed values, in original order.
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var results: [T] = []
        results.reserveCapacity(underestimatedCount)
        for element in self {
            results.append(try await transform(element))
        }
        return results
    }

    /// `compactMap` with an `async` transform, applied **serially** in
    /// sequence order. Rethrows the first error and stops.
    /// - Parameter transform: The async mapping; `nil` results are dropped.
    /// - Returns: The non-`nil` transformed values, in original order.
    func asyncCompactMap<T>(_ transform: (Element) async throws -> T?) async rethrows -> [T] {
        var results: [T] = []
        for element in self {
            if let value = try await transform(element) {
                results.append(value)
            }
        }
        return results
    }

    /// `forEach` with an `async` body, applied **serially** in sequence
    /// order. Rethrows the first error and stops — unlike the standard
    /// `forEach`, the body may throw.
    /// - Parameter body: The async work performed per element.
    func asyncForEach(_ body: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await body(element)
        }
    }
}

public extension Sequence where Element: Sendable {
    /// `map` with an `async` transform, running **all elements
    /// concurrently** in a task group while preserving original order
    /// in the result. The first error cancels the remaining work and
    /// is rethrown.
    ///
    /// Use for independent I/O-bound work (fetch N thumbnails, resolve
    /// N endpoints); prefer ``asyncMap(_:)`` when order of *execution*
    /// matters or the transform touches shared state.
    /// - Parameter transform: The async mapping applied to each element.
    /// - Returns: The transformed values, in original order.
    func concurrentMap<T: Sendable>(
        _ transform: @escaping @Sendable (Element) async throws -> T
    ) async throws -> [T] {
        let elements = Array(self)
        return try await withThrowingTaskGroup(of: (Int, T).self) { group in
            for (index, element) in elements.enumerated() {
                group.addTask {
                    (index, try await transform(element))
                }
            }
            var results = [T?](repeating: nil, count: elements.count)
            for try await (index, value) in group {
                results[index] = value
            }
            // Every slot is filled: the group completed without throwing,
            // and each child task wrote exactly one index.
            return results.compactMap { $0 }
        }
    }
}
