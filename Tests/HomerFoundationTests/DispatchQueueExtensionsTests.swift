import Testing
import Foundation
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
}
