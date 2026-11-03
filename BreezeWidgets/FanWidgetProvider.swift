import WidgetKit

struct FanWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> FanWidgetEntry {
        FanWidgetEntry(date: .now, fan: Fan.examples[0])
    }

    func snapshot(for configuration: FanWidgetConfiguration, in context: Context) async -> FanWidgetEntry {
        entry(for: configuration)
    }

    func timeline(for configuration: FanWidgetConfiguration, in context: Context) async -> Timeline<FanWidgetEntry> {
        let current = entry(for: configuration)
        var entries = [current]

        // A second entry lets the widget show the demo fan off at its deadline.
        if let deadline = current.fan.turnsOffAt, deadline > current.date {
            var stoppedFan = current.fan
            stoppedFan.isOn = false
            stoppedFan.turnsOffAt = nil
            entries.append(FanWidgetEntry(date: deadline, fan: stoppedFan))
        }

        return Timeline(entries: entries, policy: .after(.now.addingTimeInterval(900)))
    }

    private func entry(for configuration: FanWidgetConfiguration) -> FanWidgetEntry {
        let fans = FanStorage().loadFans()
        var fan = fans.first { $0.id == configuration.fan?.id } ?? Fan.examples[0]
        if let deadline = fan.turnsOffAt, deadline <= .now {
            fan.isOn = false
            fan.turnsOffAt = nil
        }
        return FanWidgetEntry(date: .now, fan: fan)
    }
}
