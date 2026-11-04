import AppIntents

struct DecreaseConnectedFanSpeedIntent: AppIntent {
    static let title: LocalizedStringResource = "Decrease fan speed"
    static var openAppWhenRun: Bool { false }
    @Parameter(title: "Fan") var fan: ConnectedFanEntity
    static var parameterSummary: some ParameterSummary { Summary("Decrease speed of \(\.$fan)") }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let response = try await HomeConnection.shared.changeSpeed(deviceID: fan.id, increase: false)
        return .result(dialog: "\(response)")
    }
}
