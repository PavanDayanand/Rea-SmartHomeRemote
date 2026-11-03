import AppIntents

struct FanQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [FanEntity] {
        FanStorage().loadFans()
            .filter { identifiers.contains($0.id) }
            .map { FanEntity(fan: $0) }
    }

    func suggestedEntities() async throws -> [FanEntity] {
        FanStorage().loadFans().map { FanEntity(fan: $0) }
    }

    func defaultResult() async -> FanEntity? {
        FanStorage().loadFans().first.map { FanEntity(fan: $0) }
    }
}
