import Testing
@testable import BreezeCore

struct FanSpeedStepTests {
    @Test func movesBetweenSupportedLevelsInNumericOrder() {
        #expect(FanSpeedStep.next(current: "2", choices: ["10", "2", "5"], increase: true) == "5")
        #expect(FanSpeedStep.next(current: "5", choices: ["10", "2", "5"], increase: false) == "2")
    }
    @Test func respectsLimitsAndRejectsUnknownReports() {
        #expect(FanSpeedStep.next(current: "5", choices: ["1", "5"], increase: true) == "5")
        #expect(FanSpeedStep.next(current: "1", choices: ["1", "5"], increase: false) == "1")
        #expect(FanSpeedStep.next(current: "3", choices: ["1", "5"], increase: true) == nil)
        #expect(FanSpeedStep.next(current: "low", choices: ["low", "high"], increase: true) == nil)
    }
}
