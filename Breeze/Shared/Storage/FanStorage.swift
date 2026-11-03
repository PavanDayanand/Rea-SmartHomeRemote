import Foundation

/// App Groups let the app, Siri actions, and widget read the same preferences.
/// This stores demo settings only. Device secrets should never go in UserDefaults.
struct FanStorage {
    static let appGroup = "group.com.pavand.breeze"
    private let defaults: UserDefaults

    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults ?? UserDefaults(suiteName: Self.appGroup) ?? .standard
    }

    func loadFans() -> [Fan] {
        Fan.examples.map { example in
            guard let data = defaults.data(forKey: "fan.\(example.id)"),
                  let savedFan = try? JSONDecoder().decode(Fan.self, from: data) else {
                return example
            }
            return savedFan
        }
    }

    func save(_ fan: Fan) throws {
        let data = try JSONEncoder().encode(fan)
        defaults.set(data, forKey: "fan.\(fan.id)")
    }
}
