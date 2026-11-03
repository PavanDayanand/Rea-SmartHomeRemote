import AppIntents

extension FanMode: AppEnum {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Fan mode")
    static let caseDisplayRepresentations: [FanMode: DisplayRepresentation] = [
        .normal: "Normal",
        .turbo: "Turbo",
        .sleep: "Sleep",
        .breeze: "Breeze",
        .reverse: "Reverse"
    ]
}
