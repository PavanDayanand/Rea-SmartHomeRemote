import WidgetKit

struct ConnectedFansProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ConnectedFansEntry { ConnectedFansEntry(date: .now, fans: []) }
    func snapshot(for configuration: ConnectedFansConfiguration, in context: Context) async -> ConnectedFansEntry { entry(configuration) }
    func timeline(for configuration: ConnectedFansConfiguration, in context: Context) async -> Timeline<ConnectedFansEntry> {
        Timeline(entries: [entry(configuration)], policy: .never)
    }
    private func entry(_ configuration: ConnectedFansConfiguration) -> ConnectedFansEntry {
        let available = ConnectedFanSnapshot.load()
        let mainID = configuration.fan?.id ?? available.first?.id
        let ids = [mainID, configuration.secondFan?.id, configuration.thirdFan?.id, configuration.fourthFan?.id].compactMap { $0 }
        var selected: [ConnectedFanSnapshot] = []
        for id in ids where !selected.contains(where: { $0.id == id }) {
            if let fan = available.first(where: { $0.id == id }) { selected.append(fan) }
        }
        return ConnectedFansEntry(date: .now, fans: selected, showLighting: configuration.showLighting, showTimer: configuration.showTimer)
    }
}
