import SwiftUI
import WidgetKit

struct ConnectedFansWidgetView: View {
    let entry: ConnectedFansEntry
    @Environment(\.widgetFamily) private var family

    private var portrait: Bool { family == .systemExtraLargePortrait }
    private var panel: Bool { family != .systemSmall && family != .systemMedium }

    var body: some View {
        GeometryReader { geometry in
            content(height: geometry.size.height)
        }
        .containerBackground(.background, for: .widget)
        .widgetURL(entry.fans.first.flatMap { URL(string: "breeze://connected/\($0.id)") })
    }

    private func content(height: CGFloat) -> some View {
        let controls = visibleControls
        let gap: CGFloat = portrait ? 18 : 6
        // Divide available height between choice rows, leaving room for titles.
        let extraHeight: CGFloat = (portrait || family == .systemExtraLarge) && entry.fans.count > 1 ? 92 : 0
        let available = height - 76 - CGFloat(controls.count) * 18 - CGFloat(controls.count + 3) * gap - extraHeight
        let choiceHeight = panel ? max(28, min(80, available / CGFloat(controls.count + 1))) : 46
        return VStack(alignment: .leading, spacing: gap) {
            Label("Breeze", systemImage: "fan.ceiling.fill")
                .font(.caption.bold()).foregroundStyle(.secondary)
            if let fan = entry.fans.first {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(fan.name).font(.headline).lineLimit(1)
                        Text(fan.isOnline ? (fan.isOn == true ? "On · Speed \(fan.speed ?? "—")" : "Off") : "Offline")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    if family != .systemSmall {
                        Spacer()
                        powerLink(fan).labelStyle(.iconOnly)
                    }
                }
                if !panel { Spacer(minLength: 0) }
                if family != .systemSmall, let speeds = fan.speeds, !speeds.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(Array(speeds.prefix(6)), id: \.self) { speed in
                            Button(intent: ControlConnectedFanIntent(deviceID: fan.id, action: "speed", value: speed)) {
                                Text(speed).font(.subheadline.bold())
                                    .frame(maxWidth: .infinity, minHeight: choiceHeight)
                            }
                            .buttonStyle(.plain)
                            .background(fan.speed == speed ? Color.teal.opacity(0.25) : Color.secondary.opacity(0.15), in: .circle)
                            .foregroundStyle(fan.speed == speed ? .teal : .primary)
                            .accessibilityLabel("Set speed \(speed)")
                        }
                    }
                } else {
                    powerLink(fan).frame(maxWidth: .infinity)
                }
                if panel {
                    ForEach(controls) { control in
                        WidgetControlRow(fanID: fan.id, control: control, buttonHeight: choiceHeight)
                    }
                    if (portrait || family == .systemExtraLarge) && entry.fans.count > 1 {
                        HStack(spacing: 8) {
                            ForEach(entry.fans) { extra in
                                VStack(spacing: 4) {
                                    Text(extra.name).font(.caption2).lineLimit(1)
                                    powerLink(extra).labelStyle(.iconOnly)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            } else {
                Text("Connect your fan").font(.headline)
                Text("Open Breeze to get started.").font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var visibleControls: [WidgetFanControl] {
        (entry.fans.first?.controls ?? []).filter { control in
            let name = control.name.lowercased()
            return !name.contains("speed") && (entry.showLighting || !name.contains("light"))
                && (entry.showTimer || !(name.contains("timer") || name.contains("countdown")))
        }
    }

    private func powerLink(_ fan: ConnectedFanSnapshot) -> some View {
        Button(intent: ControlConnectedFanIntent(deviceID: fan.id, action: "power", value: fan.isOn == true ? "off" : "on")) {
            Label(fan.isOn == true ? "Turn off" : "Turn on", systemImage: "power")
                .font(.subheadline.bold()).frame(minWidth: family == .systemSmall ? 88 : 32, minHeight: panel ? 44 : 46)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .background(.teal.opacity(0.22), in: .capsule)
        .foregroundStyle(.teal)
        .accessibilityLabel("\(fan.isOn == true ? "Turn off" : "Turn on")")
    }

}
