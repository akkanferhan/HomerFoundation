import Foundation
import Testing
@testable import HomerFoundation

@Suite("Sequence+Concurrency")
struct SequenceConcurrencyTests {

    private struct TransformError: Error, Equatable {}

    // MARK: - asyncMap

    @Test("asyncMap preserves order and applies the transform serially")
    func asyncMapOrder() async throws {
        let order = Recorder()
        let result = try await [1, 2, 3].asyncMap { value in
            await order.record(value)
            return value * 10
        }
        #expect(result == [10, 20, 30])
        #expect(await order.entries == [1, 2, 3], "Serial execution must visit elements in order")
    }

    @Test("asyncMap rethrows and stops at the first error")
    func asyncMapThrows() async {
        let order = Recorder()
        await #expect(throws: TransformError.self) {
            _ = try await [1, 2, 3].asyncMap { value in
                await order.record(value)
                if value == 2 { throw TransformError() }
                return value
            }
        }
        #expect(await order.entries == [1, 2], "Elements after the failure must not be visited")
    }

    // MARK: - asyncCompactMap

    @Test("asyncCompactMap drops nil results and keeps order")
    func asyncCompactMap() async throws {
        let result = try await [1, 2, 3, 4].asyncCompactMap { value in
            value.isMultiple(of: 2) ? value * 10 : nil
        }
        #expect(result == [20, 40])
    }

    // MARK: - asyncForEach

    @Test("asyncForEach visits every element in order")
    func asyncForEach() async throws {
        let order = Recorder()
        try await [1, 2, 3].asyncForEach { await order.record($0) }
        #expect(await order.entries == [1, 2, 3])
    }

    // MARK: - concurrentMap

    @Test("concurrentMap preserves input order regardless of completion order")
    func concurrentMapOrder() async throws {
        // Later elements sleep less, so they complete first — the
        // result must still come back in input order.
        let input = Array(1...8)
        let result = try await input.concurrentMap { value in
            try await Task.sleep(for: .milliseconds(UInt64(9 - value) * 10))
            return value * 10
        }
        #expect(result == input.map { $0 * 10 })
    }

    @Test("concurrentMap actually overlaps the work")
    func concurrentMapOverlaps() async throws {
        let clock = ContinuousClock()
        let start = clock.now
        _ = try await Array(1...5).concurrentMap { _ in
            try await Task.sleep(for: .milliseconds(50))
        }
        let elapsed = clock.now - start
        // Five serial 50 ms sleeps would take ≥ 250 ms; concurrent
        // execution should finish well under that.
        #expect(elapsed < .milliseconds(200))
    }

    @Test("concurrentMap rethrows the first error")
    func concurrentMapThrows() async {
        await #expect(throws: TransformError.self) {
            _ = try await [1, 2, 3].concurrentMap { value in
                if value == 2 { throw TransformError() }
                return value
            }
        }
    }

    @Test("concurrentMap on an empty sequence returns []")
    func concurrentMapEmpty() async throws {
        let result = try await [Int]().concurrentMap { $0 }
        #expect(result.isEmpty)
    }
}

// MARK: - Helpers

private actor Recorder {
    private(set) var entries: [Int] = []

    func record(_ entry: Int) {
        entries.append(entry)
    }
}
