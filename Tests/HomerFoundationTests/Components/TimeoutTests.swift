import Foundation
import Testing
@testable import HomerFoundation

@Suite("withTimeout")
struct TimeoutTests {

    private struct OperationError: Error, Equatable {}

    @Test("returns the operation's value when it beats the limit")
    func fastOperationWins() async throws {
        let value = try await withTimeout(.seconds(5)) { 42 }
        #expect(value == 42)
    }

    @Test("throws TimeoutError when the operation exceeds the limit")
    func slowOperationTimesOut() async {
        do {
            _ = try await withTimeout(.milliseconds(50)) {
                try await Task.sleep(for: .seconds(10))
                return "never"
            }
            Issue.record("Expected TimeoutError")
        } catch let error as TimeoutError {
            #expect(error.limit == .milliseconds(50))
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("a timed-out operation receives cooperative cancellation")
    func timedOutOperationIsCancelled() async throws {
        let flag = CancellationFlag()

        _ = try? await withTimeout(.milliseconds(50)) {
            do {
                try await Task.sleep(for: .seconds(10))
            } catch {
                // Task.sleep throws CancellationError when the group
                // cancels the losing child.
                await flag.markCancelled()
            }
        }

        try await waitUntil { await flag.wasCancelled }
    }

    @Test("an operation error inside the limit propagates unchanged")
    func operationErrorPropagates() async {
        await #expect(throws: OperationError.self) {
            try await withTimeout(.seconds(5)) {
                throw OperationError()
            }
        }
    }

    @Test("TimeoutError describes its limit")
    func errorDescription() {
        let error = TimeoutError(limit: .seconds(3))
        #expect(error.description.contains("3"))
    }
}

// MARK: - Helpers

/// Polls `condition` until it holds, failing the test after ~2 seconds.
private func waitUntil(
    _ condition: @Sendable () async -> Bool
) async throws {
    for _ in 0..<200 {
        if await condition() { return }
        try await Task.sleep(for: .milliseconds(10))
    }
    Issue.record("Timed out waiting for condition")
}

private actor CancellationFlag {
    private(set) var wasCancelled = false

    func markCancelled() {
        wasCancelled = true
    }
}
