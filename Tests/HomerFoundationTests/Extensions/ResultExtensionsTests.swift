import Foundation
import Testing
@testable import HomerFoundation

@Suite("Result+Extensions")
struct ResultExtensionsTests {
    @Test("value returns the success payload, error returns nil")
    func successAccessors() {
        let result: Result<Int, ResultSampleError> = .success(42)
        #expect(result.value == 42)
        #expect(result.error == nil)
        #expect(result.isSuccess)
        #expect(!result.isFailure)
    }

    @Test("error returns the failure payload, value returns nil")
    func failureAccessors() {
        let result: Result<Int, ResultSampleError> = .failure(ResultSampleError(code: 7))
        #expect(result.value == nil)
        #expect(result.error == ResultSampleError(code: 7))
        #expect(!result.isSuccess)
        #expect(result.isFailure)
    }

    @Test("isSuccess and isFailure are mutually exclusive")
    func mutualExclusion() {
        let success: Result<String, ResultSampleError> = .success("hi")
        let failure: Result<String, ResultSampleError> = .failure(ResultSampleError(code: 1))
        #expect(success.isSuccess != success.isFailure)
        #expect(failure.isSuccess != failure.isFailure)
    }
}

// MARK: - Helpers

private struct ResultSampleError: Error, Equatable {
    let code: Int
}
