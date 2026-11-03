import WidgetKit

struct ConnectedFansProvider: TimelineProvider {
    func placeholder(in context: Context) -> ConnectedFansEntry {
        ConnectedFansEntry(date: .now, fans: [])
    }
    func getSnapshot(in context: Context, completion: @escaping (ConnectedFansEntry) -> Void) {
        completion(ConnectedFansEntry(date: .now, fans: ConnectedFanSnapshot.load()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ConnectedFansEntry>) -> Void) {
        completion(Timeline(entries: [ConnectedFansEntry(date: .now, fans: ConnectedFanSnapshot.load())], policy: .never))
    }
}
