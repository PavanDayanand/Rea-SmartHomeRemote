import AppIntents

/// These phrases appear automatically. You can also name your own shortcuts.
struct BreezeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SetFanSpeedIntent(),
            phrases: ["Set fan speed in \(.applicationName)"],
            shortTitle: "Fan speed",
            systemImageName: "fan.ceiling"
        )
        AppShortcut(
            intent: SetFanPowerIntent(),
            phrases: ["Set fan power in \(.applicationName)"],
            shortTitle: "Fan power",
            systemImageName: "power"
        )
        AppShortcut(
            intent: SetFanLightIntent(),
            phrases: ["Set fan light in \(.applicationName)"],
            shortTitle: "Fan light",
            systemImageName: "lightbulb"
        )
    }
}
