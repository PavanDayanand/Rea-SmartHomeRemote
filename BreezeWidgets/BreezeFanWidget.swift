import SwiftUI
import WidgetKit

struct BreezeFanWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "BreezeFan",
            intent: FanWidgetConfiguration.self,
            provider: FanWidgetProvider()
        ) { entry in
            FanWidgetView(entry: entry)
        }
        .configurationDisplayName("Demo fan")
        .description("Power and speed, a tap away. Demo fans only.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
