import Foundation
import Observation
import WidgetKit

/// The one place that changes fan settings. Views do not save data themselves.
/// IMPORTANT: this version changes demo data, never physical fans.
@MainActor
@Observable
final class FanStore {
    private(set) var fans: [Fan]
    var errorMessage: String?
    private let storage: FanStorage

    init(storage: FanStorage = FanStorage()) {
        self.storage = storage
        fans = storage.loadFans()
    }

    func fan(id: String) -> Fan? {
        fans.first { $0.id == id }
    }

    // The widget or Siri may have changed a setting while the app was closed.
    func refresh(now: Date = .now) {
        fans = storage.loadFans()
        for fan in fans where fan.turnsOffAt.map({ $0 <= now }) == true {
            do {
                try update(id: fan.id) {
                    $0.isOn = false
                    $0.turnsOffAt = nil
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func setPower(id: String, isOn: Bool) throws {
        try update(id: id) {
            $0.isOn = isOn
            if !isOn { $0.turnsOffAt = nil }
        }
    }

    func setSpeed(id: String, speed: Int) throws {
        guard let fan = fan(id: id) else { throw FanControlError.fanNotFound }
        guard (1...fan.speedCount).contains(speed) else { throw FanControlError.invalidSpeed }
        try update(id: id) {
            $0.speed = speed
            $0.isOn = true
        }
    }

    func setMode(id: String, mode: FanMode) throws {
        try update(id: id) { $0.mode = mode }
    }

    func setLight(id: String, level: Int) throws {
        guard (0...3).contains(level) else { throw FanControlError.invalidLightLevel }
        try update(id: id) { $0.lightLevel = level }
    }

    func setCountdown(id: String, hours: Int, now: Date = .now) throws {
        guard [0, 2, 4, 6, 8].contains(hours) else { throw FanControlError.invalidCountdown }
        try update(id: id) {
            $0.turnsOffAt = hours == 0 ? nil : now.addingTimeInterval(Double(hours) * 3600)
        }
    }

    /// Runs a throwing action from a button and makes any error visible to the user.
    func perform(_ action: () throws -> Void) {
        do {
            try action()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func update(id: String, change: (inout Fan) -> Void) throws {
        // Start with fresh storage rather than overwriting changes made by Siri.
        var latestFans = storage.loadFans()
        guard let index = latestFans.firstIndex(where: { $0.id == id }) else {
            throw FanControlError.fanNotFound
        }
        change(&latestFans[index])
        try storage.save(latestFans[index])
        fans = latestFans
        WidgetCenter.shared.reloadAllTimelines()
    }
}
