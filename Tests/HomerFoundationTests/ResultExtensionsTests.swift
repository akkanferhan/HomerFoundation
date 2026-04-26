import Testing
import Foundation
@testable import HomerFoundation

private struct SampleError: Error, Equatable {
    let code: Int
}

@Suite("Result+Extensions")
struct ResultExtensionsTests {
    @Test("value returns the success payload, error returns nil")
    func successAccessors() {
        let result: Result<Int, SampleError> = .success(42)
        #expect(result.value == 42)
        #expect(result.error == nil)
        #expect(result.isSuccess)
        #expect(!result.isFailure)
    }

    @Test("error returns the failure payload, value returns nil")
    func failureAccessors() {
        let result: Result<Int, SampleError> = .failure(SampleError(code: 7))
        #expect(result.value == nil)
        #expect(result.error == SampleError(code: 7))
        #expect(!result.isSuccess)
        #expect(result.isFailure)
    }

    @Test("isSuccess and isFailure are mutually exclusive")
    func mutualExclusion() {
        let success: Result<String, SampleError> = .success("hi")
        let failure: Result<String, SampleError> = .failure(SampleError(code: 1))
        #expect(success.isSuccess != success.isFailure)
        #expect(failure.isSuccess != failure.isFailure)
    }
}
