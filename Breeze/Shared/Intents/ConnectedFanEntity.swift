import AppIntents

struct ConnectedFanEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Connected fan")
    static let defaultQuery = ConnectedFanQuery()
    let id: String
    let name: String
    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(name)") }
}
