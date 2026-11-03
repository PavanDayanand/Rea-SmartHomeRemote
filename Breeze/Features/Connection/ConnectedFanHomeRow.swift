import SwiftUI

struct ConnectedFanHomeRow: View {
    let device: ConnectedDevice
    let open: () -> Void
    @Environment(HomeConnection.self) private var connection

    private var power: DeviceControl? {
        device.controls.first { $0.kind == "bool" && $0.name.lowercased().contains("power") }
    }
    var body: some View {
        HStack(spacing: 12) {
            Button(action: open) {
                HStack(spacing: 12) {
                    Image(systemName: "fan.ceiling.fill")
                        .font(.title2).foregroundStyle(.teal)
                        .frame(width: 48, height: 48)
                        .background(.teal.opacity(0.1), in: .circle)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(device.name).font(.headline)
                        Text(device.isOnline ? (power?.boolValue == true ? "On" : "Off") : "Offline")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open \(device.name) controls")
            if let power {
                Button {
                    connection.run {
                        try await connection.setValue(deviceID: device.id, controlID: power.id, value: !power.boolValue)
                    }
                } label: {
                    Image(systemName: "power").font(.title3)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.glass).buttonBorderShape(.circle)
                .tint(power.boolValue ? .teal : .secondary)
                .disabled(!device.isOnline || connection.isBusy)
                .accessibilityLabel("Turn \(device.name) \(power.boolValue ? "off" : "on")")
            }
        }
        .padding(.vertical, 6)
    }
}
