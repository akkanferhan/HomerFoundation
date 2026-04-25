import Testing
import Foundation
@testable import HomerFoundation

@Suite("Thread+Extensions")
struct ThreadExtensionsTests {
    @Test("threadName on main thread returns \"main\"")
    @MainActor
    func mainThreadName() {
        #expect(Thread.current.threadName == "main")
    }

    @Test("threadName on a custom-named background thread returns its name")
    func customThreadName() async {
        let label = await withCheckedContinuation { continuation in
            let thread = Thread {
                continuation.resume(returning: Thread.current.threadName)
            }
            thread.name = "homer-test-thread"
            thread.start()
        }
        #expect(label == "homer-test-thread")
    }

    @Test("queueName returns a non-empty string from any context")
    func queueNameReturnsString() async {
        let onMain = await MainActor.run { Thread.current.queueName }
        let onBackground = await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                continuation.resume(returning: Thread.current.queueName)
            }
        }
        #expect(!onMain.isEmpty)
        #expect(!onBackground.isEmpty)
    }

    @Test("printCurrent does not crash")
    func printCurrentSmoke() async {
        await MainActor.run { Thread.printCurrent() }
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                Thread.printCurrent()
                continuation.resume()
            }
        }
    }
}
