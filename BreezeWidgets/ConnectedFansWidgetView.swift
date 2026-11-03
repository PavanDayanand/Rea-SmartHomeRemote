import SwiftUI
import WidgetKit

struct ConnectedFansWidgetView: View {
    let entry: ConnectedFansEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Breeze", systemImage: "fan.ceiling.fill")
                .font(.caption.bold()).foregroundStyle(.teal)
            if let fan = entry.fans.first {
                Text(fan.name).font(.headline)
                Text(fan.summary).font(.caption).foregroundStyle(.secondary).lineLimit(3)
                Spacer(minLength: 0)
                HStack {
                    Image(systemName: fan.isOnline ? "wifi" : "wifi.slash")
                    Text("Updated")
                    Text(fan.updatedAt, style: .time)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .font(.caption2).foregroundStyle(.secondary)
            } else {
                Text("Your next breeze").font(.headline)
                Text("Connect a fan in Breeze to see it here.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .containerBackground(.background, for: .widget)
        .widgetURL(entry.fans.first.flatMap { URL(string: "breeze://connected/\($0.id)") } ?? URL(string: "breeze://home"))
    }
}
