import AppIntents

/// AppEntity teaches Shortcuts how to display and select one of our fans.
struct FanEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Demo fan")
    static let defaultQuery = FanQuery()

    let id: String
    let name: String
    let room: String

    init(fan: Fan) {
        id = fan.id
        name = fan.name
        room = fan.room
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(room) · Demo")
    }
}
