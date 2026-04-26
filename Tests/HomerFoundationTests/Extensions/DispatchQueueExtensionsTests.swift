import Foundation
import Testing
@testable import HomerFoundation

@Suite("DispatchQueue+Extensions")
struct DispatchQueueExtensionsTests {
    @Test("isMainQueue returns true when invoked on the main queue")
    func mainQueueDetected() async {
        let result = await MainActor.run { DispatchQueue.isMainQueue }
        #expect(result)
    }

    @Test("isMainQueue returns false on a detached background task")
    func backgroundQueueRejected() async {
        let result = await Task.detached { DispatchQueue.isMainQueue }.value
        #expect(!result)
    }

    @Test("isCurrent matches the queue we are currently dispatched on")
    func isCurrentMatches() async {
        let queue = DispatchQueue(label: "com.homer.tests.isCurrent")
        let result = await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: DispatchQueue.isCurrent(queue))
            }
        }
        #expect(result)
    }

    @Test("isCurrent returns false for an unrelated queue")
    func isCurrentMismatch() async {
        let queueA = DispatchQueue(label: "com.homer.tests.A")
        let queueB = DispatchQueue(label: "com.homer.tests.B")
        let result = await withCheckedContinuation { continuation in
            queueA.async {
                continuation.resume(returning: DispatchQueue.isCurrent(queueB))
            }
        }
        #expect(!result)
    }

    @Test("safeAsync executes synchronously when already on main")
    @MainActor
    func safeAsyncSyncOnMain() async {
        await confirmation { confirm in
            DispatchQueue.main.safeAsync { confirm() }
        }
    }

    @Test("safeAsync from background dispatches to target queue")
    func safeAsyncFromBackground() async {
        await confirmation { confirm in
            await Task.detached {
                DispatchQueue.main.safeAsync { confirm() }
            }.value
            try? await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test("asyncAfter(delay:) eventually runs the work")
    func asyncAfterDelay() async {
        await confirmation { confirm in
            DispatchQueue.global().asyncAfter(delay: 0.01) { confirm() }
            try? await Task.sleep(for: .milliseconds(100))
        }
    }

    @Test("log does not crash and is safe to call from any queue")
    func logSmoke() async {
        DispatchQueue.log("test-action")
        await Task.detached { DispatchQueue.log("from-detached") }.value
    }

    @Test("debounce fires action only once for a burst of calls")
    func debounceCollapsesBurst() async {
        let counter = DebounceCounter()
        let debounced = DispatchQueue.global().debounce(delay: 0.05) {
            Task { await counter.increment() }
        }
        for _ in 0..<5 {
            debounced()
        }
        try? await Task.sleep(for: .milliseconds(250))
        let count = await counter.value
        #expect(count == 1)
    }

    @Test("debounce fires once per spaced-out call")
    func debounceFiresEachSpacedCall() async {
        let counter = DebounceCounter()
        let debounced = DispatchQueue.global().debounce(delay: 0.02) {
            Task { await counter.increment() }
        }
        debounced()
        try? await Task.sleep(for: .milliseconds(80))
        debounced()
        try? await Task.sleep(for: .milliseconds(80))
        let count = await counter.value
        #expect(count == 2)
    }
}

// MARK: - Helpers

private actor DebounceCounter {
    private(set) var value: Int = 0
    func increment() { value += 1 }
}
