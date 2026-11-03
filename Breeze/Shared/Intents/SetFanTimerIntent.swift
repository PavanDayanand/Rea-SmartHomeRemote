import AppIntents

struct SetFanTimerIntent: AppIntent {
    static let title: LocalizedStringResource = "Set Demo Fan Timer"
    static let description = IntentDescription("Set 2, 4, 6, or 8 hours; choose 0 to cancel. Demo only, reconciled on refresh.")

    @Parameter(title: "Fan") var fan: FanEntity
    @Parameter(title: "Hours", default: 2, inclusiveRange: (0, 8)) var hours: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$fan) timer to \(\.$hours) hours")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = FanStore()
        store.refresh()
        try store.setCountdown(id: fan.id, hours: hours)
        return .result(dialog: "Demo timer updated. This does not schedule your physical fan.")
    }
}
