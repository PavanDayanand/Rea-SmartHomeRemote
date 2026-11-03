import Foundation

/// Shared display data only. No account credentials or Wi-Fi passwords.
struct ConnectedFanSnapshot: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let isOnline: Bool
    let summary: String
    let updatedAt: Date
    var controls: [WidgetFanControl]? = nil
    var isOn: Bool? = nil
    var speed: String? = nil
    var speeds: [String]? = nil

    static func load() -> [Self] {
        guard let data = UserDefaults(suiteName: FanStorage.appGroup)?.data(forKey: "connected.fans"),
              let fans = try? JSONDecoder().decode([Self].self, from: data) else { return [] }
        return fans
    }

    static func save(_ fans: [Self]) {
        guard let data = try? JSONEncoder().encode(fans) else { return }
        UserDefaults(suiteName: FanStorage.appGroup)?.set(data, forKey: "connected.fans")
    }
}
