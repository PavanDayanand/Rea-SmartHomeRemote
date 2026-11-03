import AppIntents

struct SetFanPowerIntent: AppIntent {
    static let title: LocalizedStringResource = "Set Demo Fan Power"
    static let description = IntentDescription("Turn a Breeze demo fan on or off. Does not control hardware.")

    @Parameter(title: "Fan") var fan: FanEntity
    @Parameter(title: "On", default: true) var isOn: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$fan) power to \(\.$isOn)")
    }

    init() {}

    // Widgets already know which fan and power setting their button represents.
    init(fan: FanEntity, isOn: Bool) {
        self.fan = fan
        self.isOn = isOn
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = FanStore()
        store.refresh()
        try store.setPower(id: fan.id, isOn: isOn)
        return .result(dialog: "Demo: \(fan.name) is \(isOn ? "on" : "off"). No physical fan was changed.")
    }
}
