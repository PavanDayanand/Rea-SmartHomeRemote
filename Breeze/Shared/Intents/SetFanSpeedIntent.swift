import AppIntents

struct SetFanSpeedIntent: AppIntent {
    static let title: LocalizedStringResource = "Set Demo Fan Speed"
    static let description = IntentDescription("Choose a demo fan and a speed from 1 to 6. Also turns the demo fan on.")

    @Parameter(title: "Fan") var fan: FanEntity
    @Parameter(title: "Speed", default: 2, inclusiveRange: (1, 6)) var speed: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$fan) to speed \(\.$speed)")
    }

    init() {}

    init(fan: FanEntity, speed: Int) {
        self.fan = fan
        self.speed = speed
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = FanStore()
        store.refresh()
        try store.setSpeed(id: fan.id, speed: speed)
        return .result(dialog: "Demo: \(fan.name) is set to speed \(speed). No physical fan was changed.")
    }
}
