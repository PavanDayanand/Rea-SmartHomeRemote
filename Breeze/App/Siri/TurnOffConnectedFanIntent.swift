import AppIntents

struct TurnOffConnectedFanIntent: AppIntent {
    static let title: LocalizedStringResource = "Turn off fan"
    static var openAppWhenRun: Bool { false }
    @Parameter(title: "Fan") var fan: ConnectedFanEntity
    static var parameterSummary: some ParameterSummary { Summary("Turn off \(\.$fan)") }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await HomeConnection.shared.performWidgetAction(deviceID: fan.id, action: "power", value: "off")
        return .result(dialog: "\(fan.name) turned off.")
    }
}
