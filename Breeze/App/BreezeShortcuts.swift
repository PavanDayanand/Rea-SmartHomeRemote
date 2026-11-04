import AppIntents

struct BreezeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: TurnOnConnectedFanIntent(),
            phrases: ["Turn on \(\.$fan) in \(.applicationName)", "Turn on the fan in \(.applicationName)"],
            shortTitle: "Turn on fan", systemImageName: "power")
        AppShortcut(intent: TurnOffConnectedFanIntent(),
            phrases: ["Turn off \(\.$fan) in \(.applicationName)", "Turn off the fan in \(.applicationName)"],
            shortTitle: "Turn off fan", systemImageName: "power")
        AppShortcut(intent: SetConnectedFanSpeedIntent(),
            phrases: ["Set fan speed in \(.applicationName)"],
            shortTitle: "Set speed", systemImageName: "wind")
        AppShortcut(intent: IncreaseConnectedFanSpeedIntent(),
            phrases: ["Increase \(\.$fan) speed in \(.applicationName)", "Increase fan speed in \(.applicationName)"],
            shortTitle: "Increase speed", systemImageName: "plus")
        AppShortcut(intent: DecreaseConnectedFanSpeedIntent(),
            phrases: ["Decrease \(\.$fan) speed in \(.applicationName)", "Decrease fan speed in \(.applicationName)"],
            shortTitle: "Decrease speed", systemImageName: "minus")
    }
}
