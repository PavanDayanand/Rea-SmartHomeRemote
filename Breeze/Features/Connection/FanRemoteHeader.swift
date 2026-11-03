import SwiftUI

struct FanRemoteHeader: View {
    let device: ConnectedDevice
    @Environment(HomeConnection.self) private var connection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var power: DeviceControl? {
        device.controls.first { $0.kind == "bool" && $0.name.lowercased().contains("power") }
    }
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Label(device.isOnline ? "Connected" : "Offline", systemImage: device.isOnline ? "wifi" : "wifi.slash")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text(power?.boolValue == true ? "Airflow on" : "At rest")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Image(systemName: "fanblades.fill")
                .font(.system(size: 64)).foregroundStyle(.teal)
                .symbolEffect(.rotate, options: .repeating, isActive: power?.boolValue == true && !reduceMotion)
                .frame(height: 76).accessibilityHidden(true)
            if let power {
                Picker("Power", selection: Binding(get: { power.boolValue }, set: { value in
                    connection.run {
                        try await connection.setValue(deviceID: device.id, controlID: power.id, value: value)
                    }
                })) {
                    Text("Off").tag(false)
                    Text("On").tag(true)
                }
                .pickerStyle(.segmented)
                .controlSize(.extraLarge)
                .accessibilityIdentifier("remote.power")
                .disabled(!device.isOnline || connection.isBusy)
            }
        }
        .padding(20)
        .background(.teal.opacity(0.08), in: .rect(cornerRadius: 28))
    }
}
