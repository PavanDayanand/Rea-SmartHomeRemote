import Foundation
import Testing
@testable import BreezeCore

@MainActor
struct FanStoreTests {
    private func makeStore() -> FanStore {
        let defaults = UserDefaults(suiteName: "BreezeTests.\(UUID().uuidString)")!
        return FanStore(storage: FanStorage(defaults: defaults))
    }

    @Test func speedTurnsOnFanAndSurvivesReload() throws {
        let defaults = UserDefaults(suiteName: "BreezeTests.\(UUID().uuidString)")!
        let storage = FanStorage(defaults: defaults)
        let store = FanStore(storage: storage)
        try store.setPower(id: "bedroom", isOn: false)
        try store.setSpeed(id: "bedroom", speed: 3)

        let reloaded = FanStore(storage: storage)
        #expect(reloaded.fan(id: "bedroom")?.speed == 3)
        #expect(reloaded.fan(id: "bedroom")?.isOn == true)
    }

    @Test func invalidCommandsDoNotChangeState() throws {
        let store = makeStore()
        let original = store.fans
        #expect(throws: FanControlError.self) { try store.setSpeed(id: "bedroom", speed: 7) }
        #expect(throws: FanControlError.self) { try store.setSpeed(id: "bedroom", speed: 0) }
        #expect(throws: FanControlError.self) { try store.setLight(id: "bedroom", level: 4) }
        #expect(throws: FanControlError.self) { try store.setCountdown(id: "bedroom", hours: 3) }
        #expect(throws: FanControlError.self) { try store.setPower(id: "missing", isOn: true) }
        #expect(store.fans == original)
    }

    @Test func lightDoesNotChangeFanPower() throws {
        let store = makeStore()
        try store.setPower(id: "bedroom", isOn: false)
        try store.setLight(id: "bedroom", level: 3)
        #expect(store.fan(id: "bedroom")?.lightLevel == 3)
        #expect(store.fan(id: "bedroom")?.isOn == false)
    }

    @Test func timerExpiresOnRefreshAndPreservesLight() throws {
        let store = makeStore()
        let start = Date(timeIntervalSince1970: 1000)
        try store.setPower(id: "bedroom", isOn: true)
        try store.setLight(id: "bedroom", level: 2)
        try store.setCountdown(id: "bedroom", hours: 2, now: start)
        store.refresh(now: start.addingTimeInterval(7199))
        #expect(store.fan(id: "bedroom")?.isOn == true)
        store.refresh(now: start.addingTimeInterval(7200))
        #expect(store.fan(id: "bedroom")?.isOn == false)
        #expect(store.fan(id: "bedroom")?.turnsOffAt == nil)
        #expect(store.fan(id: "bedroom")?.lightLevel == 2)
    }

    @Test func powerOffCancelsTimer() throws {
        let store = makeStore()
        try store.setCountdown(id: "bedroom", hours: 4)
        try store.setPower(id: "bedroom", isOn: false)
        #expect(store.fan(id: "bedroom")?.turnsOffAt == nil)
    }

    @Test func separateStoresPreserveEachOthersChanges() throws {
        let defaults = UserDefaults(suiteName: "BreezeTests.\(UUID().uuidString)")!
        let storage = FanStorage(defaults: defaults)
        let app = FanStore(storage: storage)
        let shortcut = FanStore(storage: storage)
        try app.setLight(id: "bedroom", level: 3)
        try shortcut.setSpeed(id: "bedroom", speed: 4)
        app.refresh()
        #expect(app.fan(id: "bedroom")?.lightLevel == 3)
        #expect(app.fan(id: "bedroom")?.speed == 4)
    }

    @Test func corruptDemoDataFallsBackToExamples() {
        let defaults = UserDefaults(suiteName: "BreezeTests.\(UUID().uuidString)")!
        defaults.set(Data("invalid".utf8), forKey: "fan.bedroom")
        let storage = FanStorage(defaults: defaults)
        #expect(storage.loadFans() == Fan.examples)
    }

    @Test func modesAndTimerCancellationPersist() throws {
        let store = makeStore()
        try store.setMode(id: "bedroom", mode: .sleep)
        try store.setCountdown(id: "bedroom", hours: 8)
        try store.setCountdown(id: "bedroom", hours: 0)
        store.refresh()
        #expect(store.fan(id: "bedroom")?.mode == .sleep)
        #expect(store.fan(id: "bedroom")?.turnsOffAt == nil)
    }
}
