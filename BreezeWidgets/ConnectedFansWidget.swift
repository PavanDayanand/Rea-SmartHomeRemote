import SwiftUI
import WidgetKit

struct ConnectedFansWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "BreezeConnectedFans", provider: ConnectedFansProvider()) { entry in
            ConnectedFansWidgetView(entry: entry)
        }
        .configurationDisplayName("Connected fan")
        .description("Last reported fan state. Tap to open live controls in Breeze.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
