import AppIntents
import WidgetKit

struct FanWidgetConfiguration: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Choose a demo fan"
    static let description = IntentDescription("Pick the fan you want on your Home Screen. Demo controls only.")

    @Parameter(title: "Fan") var fan: FanEntity?
}
