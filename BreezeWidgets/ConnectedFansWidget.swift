import SwiftUI
import WidgetKit

struct ConnectedFansWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "BreezeConnectedFans", intent: ConnectedFansConfiguration.self, provider: ConnectedFansProvider()) { entry in
            ConnectedFansWidgetView(entry: entry)
        }
        .configurationDisplayName("Connected fan")
        .description("Last reported fan state. Tap to open live controls in Breeze.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge, .systemExtraLargePortrait])
    }
}
