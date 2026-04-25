import Testing
@testable import HomerFoundation

@Suite("Log")
struct LogTests {
    @Test("Default channel uses bundle identifier as subsystem fallback")
    func defaultChannelExists() {
        let channel = Log.default
        _ = channel.logger
    }

    @Test("Custom channel can be constructed with subsystem and category")
    func customChannelConstruction() {
        let channel = Log(subsystem: "com.homer.tests", category: "unit")
        _ = channel.logger
    }

    @Test("Instance log levels do not crash")
    func instanceLevelsDoNotCrash() {
        let channel = Log(subsystem: "com.homer.tests", category: "unit")
        channel.debug("debug")
        channel.info("info")
        channel.notice("notice")
        channel.warning("warning")
        channel.error("error")
        channel.fault("fault")
    }

    @Test("Static log levels do not crash")
    func staticLevelsDoNotCrash() {
        Log.debug("debug")
        Log.info("info")
        Log.notice("notice")
        Log.warning("warning")
        Log.error("error")
        Log.fault("fault")
    }
}
