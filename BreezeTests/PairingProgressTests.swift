import Foundation
import Testing
@testable import BreezeCore

struct PairingProgressTests {
    @Test func tokenRequestHasItsOwnDeadline() {
        let start = Date(timeIntervalSince1970: 0)
        var progress = PairingProgress()
        progress.update(.token, detail: "Preparing", timeout: 25, now: start)
        #expect(!progress.hasExpired(at: start.addingTimeInterval(24)))
        #expect(progress.hasExpired(at: start.addingTimeInterval(25)))
    }

    @Test func hotSpotGetsANewDeadlineAndSDKUpdatesDoNotExtendIt() {
        let start = Date(timeIntervalSince1970: 0)
        var progress = PairingProgress()
        progress.update(.token, detail: "Preparing", timeout: 25, now: start)
        progress.update(.hotspot, detail: "Join hotspot", timeout: 600, now: start.addingTimeInterval(5))
        progress.update(.connecting, detail: "Contacting", timeout: 125, now: start.addingTimeInterval(15))
        progress.update(.found, detail: "Found", now: start.addingTimeInterval(40))
        #expect(progress.remainingSeconds(at: start.addingTimeInterval(40)) == 100)
        #expect(progress.hasExpired(at: start.addingTimeInterval(140)))
    }

    @Test func terminalStatesRemoveDeadlineAndDoNotRepeatEvents() {
        for ending in [PairingStage.complete, .failed, .cancelled] {
            var progress = PairingProgress()
            progress.update(.connecting, detail: "Contacting", timeout: 125)
            progress.update(.found, detail: "Found")
            progress.update(.found, detail: "Found again")
            #expect(progress.events.count == 2)
            progress.update(ending, detail: "Done")
            #expect(progress.deadline == nil)
            #expect(!progress.hasExpired(at: .distantFuture))
        }
    }
}
