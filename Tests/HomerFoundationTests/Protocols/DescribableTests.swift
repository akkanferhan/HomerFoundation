import Foundation
import Testing
@testable import HomerFoundation

@Suite("Describable")
struct DescribableTests {
    @Test("Struct typeName matches its name")
    func structTypeName() {
        let sample = DescribableSample()
        #expect(sample.typeName == "DescribableSample")
        #expect(DescribableSample.typeName == "DescribableSample")
    }

    @Test("Class typeName matches its name")
    func classTypeName() {
        let sample = DescribableSampleClass()
        #expect(sample.typeName == "DescribableSampleClass")
        #expect(DescribableSampleClass.typeName == "DescribableSampleClass")
    }
}

// MARK: - Helpers

private struct DescribableSample: Describable {}

private final class DescribableSampleClass: Describable {}
