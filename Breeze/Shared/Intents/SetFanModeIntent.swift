import AppIntents

struct SetFanModeIntent: AppIntent {
    static let title: LocalizedStringResource = "Set Demo Fan Mode"
    static let description = IntentDescription("Choose Normal, Turbo, Sleep, Breeze, or Reverse for a demo fan.")

    @Parameter(title: "Fan") var fan: FanEntity
    @Parameter(title: "Mode", default: .normal) var mode: FanMode

    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$fan) to \(\.$mode) mode")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = FanStore()
        store.refresh()
        try store.setMode(id: fan.id, mode: mode)
        return .result(dialog: "Demo fan mode updated. No physical fan was changed.")
    }
}
