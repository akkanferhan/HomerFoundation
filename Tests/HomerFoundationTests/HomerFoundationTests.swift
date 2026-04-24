import Testing
@testable import HomerFoundation

@Suite("HomerFoundation")
struct HomerFoundationTests {
    @Test("Version is exposed")
    func versionIsExposed() {
        #expect(HomerFoundation.version == "0.1.0")
    }
}
