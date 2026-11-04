import AppIntents

struct IncreaseConnectedFanSpeedIntent: AppIntent {
    static let title: LocalizedStringResource = "Increase fan speed"
    static var openAppWhenRun: Bool { false }
    @Parameter(title: "Fan") var fan: ConnectedFanEntity
    static var parameterSummary: some ParameterSummary { Summary("Increase speed of \(\.$fan)") }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let response = try await HomeConnection.shared.changeSpeed(deviceID: fan.id, increase: true)
        return .result(dialog: "\(response)")
    }
}
