import SwiftUI
import WidgetKit

struct FanWidgetView: View {
    let entry: FanWidgetEntry
    @Environment(\.widgetFamily) private var family

    private var fan: Fan { entry.fan }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Breeze · Demo", systemImage: "fan.ceiling.fill")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fan.room).font(.headline)
                    Text(fan.summary).font(.subheadline).foregroundStyle(.secondary)
                }
                if family == .systemMedium {
                    Spacer()
                    powerButton.labelStyle(.iconOnly)
                }
            }
            Spacer(minLength: 0)
            if family == .systemMedium {
                speedButtons
            } else {
                powerButton.frame(maxWidth: .infinity)
            }
        }
        .containerBackground(.background, for: .widget)
        .widgetURL(URL(string: "breeze://fan/\(fan.id)"))
    }

    private var powerButton: some View {
        Button(intent: SetFanPowerIntent(fan: FanEntity(fan: fan), isOn: !fan.isOn)) {
            Label(fan.isOn ? "Turn off" : "Turn on", systemImage: "power")
                .font(.subheadline.bold())
                .frame(minWidth: 32, minHeight: 32)
        }
        .tint(.teal)
        .accessibilityLabel("\(fan.isOn ? "Turn off" : "Turn on") demo fan")
    }

    private var speedButtons: some View {
        HStack(spacing: 6) {
            ForEach(1...fan.speedCount, id: \.self) { speed in
                Button(intent: SetFanSpeedIntent(fan: FanEntity(fan: fan), speed: speed)) {
                    Text(speed, format: .number)
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
                .tint(speed == fan.speed ? .teal : .secondary)
                .accessibilityLabel("Set demo fan speed to \(speed)")
                .accessibilityAddTraits(speed == fan.speed ? .isSelected : [])
            }
        }
    }
}
