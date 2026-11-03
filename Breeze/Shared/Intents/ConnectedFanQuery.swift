import AppIntents

struct ConnectedFanQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [ConnectedFanEntity] {
        ConnectedFanSnapshot.load().filter { identifiers.contains($0.id) }.map { ConnectedFanEntity(id: $0.id, name: $0.name) }
    }
    func suggestedEntities() async throws -> [ConnectedFanEntity] {
        ConnectedFanSnapshot.load().map { ConnectedFanEntity(id: $0.id, name: $0.name) }
    }
    func defaultResult() async -> ConnectedFanEntity? {
        ConnectedFanSnapshot.load().first.map { ConnectedFanEntity(id: $0.id, name: $0.name) }
    }
}
