import Testing
@testable import HomerFoundation

private struct Sample: Describable {}

private final class SampleClass: Describable {}

@Suite("Describable")
struct DescribableTests {
    @Test("Struct typeName matches its name")
    func structTypeName() {
        let sample = Sample()
        #expect(sample.typeName == "Sample")
        #expect(Sample.typeName == "Sample")
    }

    @Test("Class typeName matches its name")
    func classTypeName() {
        let sample = SampleClass()
        #expect(sample.typeName == "SampleClass")
        #expect(SampleClass.typeName == "SampleClass")
    }
}
