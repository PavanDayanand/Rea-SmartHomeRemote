import SwiftUI

struct ConnectedDeviceView: View {
    let deviceID: String
    @Environment(HomeConnection.self) private var connection

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var expandedControlID: String?
    @State private var showingRename = false
    @State private var newName = ""

    var body: some View {
        if let device = connection.devices.first(where: { $0.id == deviceID }) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    FanRemoteHeader(device: device)
                    let quick = device.controls.filter {
                        let name = $0.name.lowercased()
                        return name.contains("speed") || name.contains("mode") || name.contains("timer") || name.contains("countdown")
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                        ForEach(quick) { control in
                            RemoteControlTile(control: control, isExpanded: expandedControlID == control.id) {
                                withAnimation(reduceMotion ? nil : .snappy(duration: 0.25)) {
                                    expandedControlID = expandedControlID == control.id ? nil : control.id
                                }
                            }
                        }
                    }
                    .disabled(!device.isOnline || connection.isBusy)
                    if let expanded = quick.first(where: { $0.id == expandedControlID }) {
                        DeviceControlView(deviceID: device.id, control: expanded)
                            .padding(20)
                            .background(.secondary.opacity(0.07), in: .rect(cornerRadius: 22))
                            .disabled(!device.isOnline || connection.isBusy)
                    }
                    ForEach(device.controls.filter { control in
                        !control.name.lowercased().contains("power") && !quick.contains(where: { $0.id == control.id })
                    }) { control in
                        DeviceControlView(deviceID: device.id, control: control)
                            .padding(20)
                            .background(.secondary.opacity(0.07), in: .rect(cornerRadius: 22))
                            .disabled(!device.isOnline || connection.isBusy)
                    }
                    if let message = connection.message {
                        Text(message).font(.footnote).foregroundStyle(.secondary)
                    }
                }
                .padding(20)
            }
            .task(id: device.id) {
                if expandedControlID == nil {
                    expandedControlID = device.controls.first(where: { $0.name.lowercased().contains("speed") })?.id
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("Fan options", systemImage: "ellipsis") {
                        Button("Rename fan", systemImage: "pencil") {
                            newName = device.name
                            showingRename = true
                        }
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
        } else if connection.isBusy {
            ProgressView("Loading fan…")
        } else {
            ContentUnavailableView("Device not found", systemImage: "fan.ceiling")
        }
    }
}
