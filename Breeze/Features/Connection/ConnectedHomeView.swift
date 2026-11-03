import SwiftUI

struct ConnectedHomeView: View {
    @Environment(HomeConnection.self) private var connection
    var previewDeviceID: String? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appliedInitialRoute = false
    @State private var path: [String] = []
    @State private var showingPairing = false
    @State private var showingDemo = false

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if !connection.isConfigured {
                    SDKSetupView()
                } else if !connection.isLoggedIn {
                    ConnectionLoginView()
                } else if !connection.hasHome {
                    CreateHomeView()
                } else {
                    devicesList
                }
            }
            .navigationTitle("Breeze")
            .toolbar {
                if !connection.isConfigured {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Explore demo controls", systemImage: "sparkles") { showingDemo = true }
                    }
                }
                if connection.isLoggedIn && connection.hasHome {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add fan", systemImage: "plus") { showingPairing = true }
                    }
                }
            }
            .navigationDestination(for: String.self) { id in
                ConnectedDeviceView(deviceID: id)
                    .toolbar(.hidden, for: .tabBar)
            }
            .onChange(of: connection.navigationRequest) { _, _ in
                if let id = connection.requestedDeviceID {
                    path = [id]
                    connection.requestedDeviceID = nil
                }
            }
            .sheet(isPresented: $showingPairing) { AddFanView().environment(connection) }
            .sheet(isPresented: $showingDemo) { HomeView().environment(connection) }
            .alert("Connection issue", isPresented: Binding(
                get: { connection.errorMessage != nil },
                set: { if !$0 { connection.errorMessage = nil } }
            )) {
                Button("OK") { connection.errorMessage = nil }
            } message: {
                Text(connection.errorMessage ?? "Please try again.")
            }
            .task {
                connection.run { try await connection.loadHome() }
                if !appliedInitialRoute {
                    appliedInitialRoute = true
                    if let id = connection.requestedDeviceID ?? previewDeviceID {
                        path = [id]
                        connection.requestedDeviceID = nil
                    }
                }
            }
        }
    }

    private var devicesList: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Label(connection.homeName, systemImage: "house")
                            .font(.headline)
                        Spacer()
                        if connection.isBusy {
                            Image(systemName: "fanblades.fill")
                                .foregroundStyle(.teal)
                                .symbolEffect(.rotate, options: .repeating, isActive: !reduceMotion)
                                .accessibilityLabel("Refreshing fans")
                        }
                        Text("\(connection.devices.count) fans")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    Divider()
                    HomeWeatherCard()
                }
                .padding(.vertical, 4)
            }
            Section {
                HomeStatusSummary(devices: connection.devices)
            }
            Section("Your devices") {
                if connection.devices.isEmpty {
                    ContentUnavailableView("Add your first fan", systemImage: "fan.ceiling", description: Text("Tap + to connect an Orient fan to your home."))
                }
                ForEach(connection.devices) { device in
                    ConnectedFanHomeRow(device: device) { path.append(device.id) }
                }
            }
            if let message = connection.message {
                Section { Text(message).font(.footnote).foregroundStyle(.secondary) }
            }
        }
        .refreshable { connection.run { try await connection.refreshDevices() } }
    }
}
