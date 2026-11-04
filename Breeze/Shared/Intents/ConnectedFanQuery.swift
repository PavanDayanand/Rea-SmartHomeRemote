import AppIntents
import Foundation

struct ConnectedFanQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [ConnectedFanEntity] {
        ConnectedFanSnapshot.load().filter { identifiers.contains($0.id) }.map { ConnectedFanEntity(id: $0.id, name: $0.name) }
    }
    func suggestedEntities() async throws -> [ConnectedFanEntity] {
        ConnectedFanSnapshot.load().map { ConnectedFanEntity(id: $0.id, name: $0.name) }
    }
    func entities(matching string: String) async throws -> [ConnectedFanEntity] {
        try await suggestedEntities().filter { $0.name.localizedStandardContains(string) }
    }
    func defaultResult() async -> ConnectedFanEntity? {
        let fans = ConnectedFanSnapshot.load()
        let defaultID = UserDefaults(suiteName: FanStorage.appGroup)?.string(forKey: "siri.defaultFanID")
        guard let fan = fans.first(where: { $0.id == defaultID }) ?? (fans.count == 1 ? fans.first : nil) else { return nil }
        return ConnectedFanEntity(id: fan.id, name: fan.name)
    }
}
