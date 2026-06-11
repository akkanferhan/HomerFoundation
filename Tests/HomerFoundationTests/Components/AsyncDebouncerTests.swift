import Foundation
import Testing
@testable import HomerFoundation

@Suite("AsyncDebouncer")
struct AsyncDebouncerTests {

    @Test("a burst of calls runs only the latest operation")
    func burstCollapsesToLatest() async throws {
        let debouncer = AsyncDebouncer(interval: .milliseconds(80))
        let recorder = Recorder()

        await debouncer.call { await recorder.record("first") }
        await debouncer.call { await recorder.record("second") }
        await debouncer.call { await recorder.record("third") }

        try await waitUntil { await recorder.entries.isNotEmpty }
        // Quiet period: nothing else may arrive after the survivor ran.
        try await Task.sleep(for: .milliseconds(150))
        #expect(await recorder.entries == ["third"])
    }

    @Test("calls spaced beyond the interval each run")
    func spacedCallsAllRun() async throws {
        let debouncer = AsyncDebouncer(interval: .milliseconds(40))
        let recorder = Recorder()

        await debouncer.call { await recorder.record("first") }
        try await waitUntil { await recorder.entries.count == 1 }

        await debouncer.call { await recorder.record("second") }
        try await waitUntil { await recorder.entries.count == 2 }

        #expect(await recorder.entries == ["first", "second"])
    }

    @Test("cancel prevents the pending operation from running")
    func cancelDropsPendingOperation() async throws {
        let debouncer = AsyncDebouncer(interval: .milliseconds(60))
        let recorder = Recorder()

        await debouncer.call { await recorder.record("doomed") }
        await debouncer.cancel()

        try await Task.sleep(for: .milliseconds(200))
        #expect(await recorder.entries.isEmpty)
    }

    @Test("a call after cancel schedules normally")
    func callAfterCancelRuns() async throws {
        let debouncer = AsyncDebouncer(interval: .milliseconds(40))
        let recorder = Recorder()

        await debouncer.call { await recorder.record("doomed") }
        await debouncer.cancel()
        await debouncer.call { await recorder.record("survivor") }

        try await waitUntil { await recorder.entries.isNotEmpty }
        #expect(await recorder.entries == ["survivor"])
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

private actor Recorder {
    private(set) var entries: [String] = []

    func record(_ entry: String) {
        entries.append(entry)
    }
}
