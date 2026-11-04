import Foundation

/// Keep the device's raw values while comparing their numeric speed levels.
enum FanSpeedStep {
    static func next(current: String, choices: [String], increase: Bool) -> String? {
        let speeds = choices.compactMap { raw -> (String, Int)? in
            guard let number = Int(raw) else { return nil }
            return (raw, number)
        }.sorted { $0.1 < $1.1 }
        guard speeds.count == choices.count,
              let index = speeds.firstIndex(where: { $0.0 == current }) else { return nil }
        let nextIndex = increase ? index + 1 : index - 1
        guard speeds.indices.contains(nextIndex) else { return current }
        return speeds[nextIndex].0
    }
}
