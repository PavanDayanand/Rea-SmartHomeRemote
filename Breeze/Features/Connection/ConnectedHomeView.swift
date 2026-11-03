import SwiftUI

struct ConnectedHomeView: View {
    @Environment(HomeConnection.self) private var connection
    @State private var showingPairing = false
    @State private var showingDemo = false

    var body: some View {
        NavigationStack {
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
            .sheet(isPresented: $showingPairing) { AddFanView() }
            .sheet(isPresented: $showingDemo) { HomeView() }
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
            }
        }
    }

    private var devicesList: some View {
        List {
            Section {
                FanConnectionHeader(
                    title: connection.homeName,
                    subtitle: connection.devices.isEmpty
                        ? "Your favourite spot, a little cooler. Add your first fan to get started."
                        : "Your fans, all in one place."
                )
                .listRowBackground(Color.clear)
            }
            Section("Your devices") {
                if connection.devices.isEmpty {
                    ContentUnavailableView("Add your first fan", systemImage: "fan.ceiling", description: Text("Tap + to connect an Orient fan to your home."))
                }
                ForEach(connection.devices) { device in
                    NavigationLink {
                        ConnectedDeviceView(deviceID: device.id)
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(device.name)
                                Text(device.isOnline ? "Online" : "Offline")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "fan.ceiling.fill").foregroundStyle(.teal)
                        }
                    }
                }
            }
            if let message = connection.message {
                Section { Text(message).font(.footnote).foregroundStyle(.secondary) }
            }
        }
        .refreshable { connection.run { try await connection.refreshDevices() } }
        .overlay {
            if connection.isBusy { ProgressView().padding().background(.regularMaterial, in: .capsule) }
        }
    }
}
