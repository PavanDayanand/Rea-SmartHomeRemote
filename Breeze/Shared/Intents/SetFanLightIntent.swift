import AppIntents

struct SetFanLightIntent: AppIntent {
    static let title: LocalizedStringResource = "Set Demo Fan Light"
    static let description = IntentDescription("Set a demo light to level 1, 2, or 3. Choose 0 to turn it off.")

    @Parameter(title: "Fan") var fan: FanEntity
    @Parameter(title: "Light level", default: 1, inclusiveRange: (0, 3)) var level: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$fan) light to level \(\.$level)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = FanStore()
        store.refresh()
        try store.setLight(id: fan.id, level: level)
        return .result(dialog: "Demo light level set to \(level). No physical light was changed.")
    }
}
