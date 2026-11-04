import AppIntents

struct TurnOnConnectedFanIntent: AppIntent {
    static let title: LocalizedStringResource = "Turn on fan"
    static var openAppWhenRun: Bool { false }
    @Parameter(title: "Fan") var fan: ConnectedFanEntity
    static var parameterSummary: some ParameterSummary { Summary("Turn on \(\.$fan)") }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await HomeConnection.shared.performWidgetAction(deviceID: fan.id, action: "power", value: "on")
        return .result(dialog: "\(fan.name) turned on.")
    }
}
