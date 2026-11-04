import AppIntents

struct SetConnectedFanSpeedIntent: AppIntent {
    static let title: LocalizedStringResource = "Set fan speed"
    static var openAppWhenRun: Bool { false }
    @Parameter(title: "Fan") var fan: ConnectedFanEntity
    @Parameter(title: "Speed") var speed: Int
    static var parameterSummary: some ParameterSummary { Summary("Set \(\.$fan) to speed \(\.$speed)") }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await HomeConnection.shared.performWidgetAction(deviceID: fan.id, action: "speed", value: String(speed))
        return .result(dialog: "\(fan.name) set to speed \(speed).")
    }
}
