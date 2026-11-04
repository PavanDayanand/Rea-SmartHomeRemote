import SwiftUI

struct BreezeSettingsView: View {
    @Environment(HomeConnection.self) private var connection

    var body: some View {
        NavigationStack {
            Form {
                Section("Your home") {
                    LabeledContent("Home", value: connection.homeName)
                    LabeledContent("Fans", value: connection.devices.count.formatted())
                    Label(connection.isLoggedIn ? "Account connected" : "Sign in from Home", systemImage: "person.crop.circle")
                }
                Section("Siri") {
                    NavigationLink { SiriSettingsView() } label: {
                        Label("Siri & Shortcuts", systemImage: "waveform")
                    }
                }
                Section("Widgets") {
                    Label("Controls without opening the app", systemImage: "square.grid.2x2")
                    Text("Long-press a widget and choose Edit Widget to select its fan. Small has power, medium adds speed, and large adds mode, timer and lighting.")
                    Text("Choose the tall Extra Large Portrait widget for the full remote and extra fan power shortcuts.")
                }
                Section("Setup & help") {
                    NavigationLink { PairingGuideView() } label: { Label("Remote pairing guide", systemImage: "book") }
                    Text("Allow Local Network access in iPhone Settings. Automatic Wi-Fi name detection is unavailable with this build’s signing account.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section {
                    LabeledContent("Breeze", value: "Personal edition")
                    Text("Your fan controls use the device service. No AI features.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
