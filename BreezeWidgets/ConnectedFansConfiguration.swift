import AppIntents

struct ConnectedFansConfiguration: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Fan controls"
    static let description = IntentDescription("Choose your main fan and optional extra power shortcuts for larger widgets.")
    @Parameter(title: "Main fan") var fan: ConnectedFanEntity?
    @Parameter(title: "Second fan") var secondFan: ConnectedFanEntity?
    @Parameter(title: "Third fan") var thirdFan: ConnectedFanEntity?
    @Parameter(title: "Fourth fan") var fourthFan: ConnectedFanEntity?
    @Parameter(title: "Show lighting", default: true) var showLighting: Bool
    @Parameter(title: "Show timer", default: true) var showTimer: Bool
    static var parameterSummary: some ParameterSummary {
        Switch(.widgetFamily) {
            Case(.systemSmall) {
                Summary { \.$fan }
            }
            Case(.systemMedium) {
                Summary { \.$fan }
            }
            Case(.systemLarge) {
                Summary {
                    \.$fan
                    \.$showLighting
                    \.$showTimer
                }
            }
            DefaultCase {
                Summary {
                    \.$fan
                    \.$secondFan
                    \.$thirdFan
                    \.$fourthFan
                    \.$showLighting
                    \.$showTimer
                }
            }
        }
    }
}
