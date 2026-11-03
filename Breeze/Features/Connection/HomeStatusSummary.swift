import SwiftUI

struct HomeStatusSummary: View {
    let devices: [ConnectedDevice]

    private var running: Int {
        devices.filter { device in
            device.isOnline && device.controls.contains { $0.kind == "bool" && $0.name.lowercased().contains("power") && $0.boolValue }
        }.count
    }
    private var lights: Int {
        devices.filter { device in
            device.isOnline && device.controls.contains {
                guard $0.name.lowercased().contains("light") else { return false }
                if $0.kind == "bool" { return $0.boolValue }
                return !["off", "0", ""].contains($0.textValue.lowercased())
            }
        }.count
    }
    var body: some View {
        HStack(spacing: 16) {
            activity(count: running, title: "Fans running", symbol: "fanblades.fill", color: .teal)
            Divider()
            activity(count: lights, title: "Lights on", symbol: "lightbulb.fill", color: .orange)
        }
        .padding(.vertical, 8)
    }

    private func activity(count: Int, title: String, symbol: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(count > 0 ? color : .secondary)
                .frame(width: 36, height: 36)
                .background(color.opacity(count > 0 ? 0.12 : 0.04), in: .circle)
            VStack(alignment: .leading, spacing: 2) {
                Text(count, format: .number).font(.title3.bold()).monospacedDigit()
                Text(title).font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
