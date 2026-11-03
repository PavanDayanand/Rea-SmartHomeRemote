import SwiftUI

struct ConnectedDeviceView: View {
    let deviceID: String
    @Environment(HomeConnection.self) private var connection

    @State private var showingRename = false
    @State private var newName = ""

    var body: some View {
        if let device = connection.devices.first(where: { $0.id == deviceID }) {
            Form {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "fan.ceiling.fill")
                            .font(.largeTitle).foregroundStyle(.teal)
                            .padding(16).background(.teal.opacity(0.12), in: .circle)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(device.name).font(.title2.bold())
                            Label(device.isOnline ? "Online" : "Offline", systemImage: device.isOnline ? "wifi" : "wifi.slash")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                Section("Fan controls") {
                    ForEach(device.controls) { control in
                        DeviceControlView(deviceID: device.id, control: control)
                    }
                    .disabled(!device.isOnline || connection.isBusy)
                }
                if let message = connection.message {
                    Section { Text(message).font(.footnote).foregroundStyle(.secondary) }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Rename fan", systemImage: "pencil") {
                        newName = device.name
                        showingRename = true
                    }
                    .disabled(connection.isBusy)
                }
            }
            .alert("Rename fan", isPresented: $showingRename) {
                TextField("Fan name", text: $newName)
                Button("Save") {
                    connection.run { try await connection.renameDevice(deviceID: deviceID, name: newName) }
                }
                Button("Cancel", role: .cancel) { }
            }
            .navigationTitle(device.name)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable { connection.run { try await connection.refreshDevices() } }
        } else {
            ContentUnavailableView("Device not found", systemImage: "fan.ceiling")
        }
    }
}
