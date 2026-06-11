import Foundation
import Testing
@testable import HomerFoundation

@Suite("AsyncThrottler")
struct AsyncThrottlerTests {

    @Test("the first call in a window runs immediately")
    func leadingCallRunsImmediately() async throws {
        let throttler = AsyncThrottler(interval: .seconds(60))
        let recorder = Recorder()

        await throttler.call { await recorder.record("first") }

        try await waitUntil { await recorder.entries == ["first"] }
    }

    @Test("a burst runs the first call immediately and the latest at window end")
    func burstRunsLeadingAndTrailingLatest() async throws {
        let throttler = AsyncThrottler(interval: .milliseconds(100))
        let recorder = Recorder()

        await throttler.call { await recorder.record("first") }
        await throttler.call { await recorder.record("dropped") }
        await throttler.call { await recorder.record("latest") }

        try await waitUntil { await recorder.entries.count == 2 }
        // Quiet period: nothing else may arrive after the trailing run.
        try await Task.sleep(for: .milliseconds(150))
        #expect(await recorder.entries == ["first", "latest"])
    }

    @Test("calls spaced beyond the interval each run immediately")
    func spacedCallsRunImmediately() async throws {
        let throttler = AsyncThrottler(interval: .milliseconds(40))
        let recorder = Recorder()

        await throttler.call { await recorder.record("first") }
        try await waitUntil { await recorder.entries.count == 1 }
        try await Task.sleep(for: .milliseconds(60))

        await throttler.call { await recorder.record("second") }
        try await waitUntil { await recorder.entries.count == 2 }

        #expect(await recorder.entries == ["first", "second"])
    }

    @Test("cancel drops the trailing operation")
    func cancelDropsTrailing() async throws {
        let throttler = AsyncThrottler(interval: .milliseconds(80))
        let recorder = Recorder()

        await throttler.call { await recorder.record("first") }
        await throttler.call { await recorder.record("doomed") }
        await throttler.cancel()

        try await Task.sleep(for: .milliseconds(200))
        #expect(await recorder.entries == ["first"])
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
