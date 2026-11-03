import SwiftUI

struct AddFanView: View {
    @Environment(HomeConnection.self) private var connection
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var wifi = CurrentWiFi()
    @State private var useDetectedNetwork = false
    // Remember only the network name; never persist the Wi-Fi password.
    @AppStorage("pairing.homeSSID") private var ssid = ""
    @State private var password = ""
    @State private var useAPMode = true
    @State private var isReady = false
    @State private var showingGuide = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FanConnectionHeader(
                        title: connection.isPairing ? "Bringing your fan home" : "A little more breeze",
                        subtitle: "Connect your Orient Aeroslim to your home.",
                        isConnecting: connection.isPairing && !connection.isReadyForHotspot
                    )
                    Text("Pairing may move this fan from its existing account. Test one fan first, once you are ready to change its connection.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Your home Wi-Fi") {
                    if wifi.isAvailable {
                        Button {
                            useDetectedNetwork = true
                            wifi.detect()
                        } label: {
                            Label("Use current Wi-Fi", systemImage: "wifi")
                        }
                        .disabled(wifi.isChecking)
                    }
                    if wifi.isChecking { ProgressView("Reading Wi-Fi name…") }
                    Text(wifi.explanation)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    TextField("2.4 GHz Wi-Fi name", text: $ssid)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Wi-Fi password", text: $password)
                    Picker("Pairing mode", selection: $useAPMode) {
                        Text("AP · slow blinking").tag(true)
                        Text("EZ · fast blinking").tag(false)
                    }
                    if !useAPMode && !connection.supportsEZPairing {
                        Label("EZ isn’t available in this build. Select AP and use slow blinking with a visible fan hotspot.", systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                    }
                }
                .disabled(connection.isPairing)

                Section("Prepare the fan") {
                    Button("Show remote pairing guide", systemImage: "book") { showingGuide = true }
                        .disabled(connection.isPairing)
                    if useAPMode {
                        Text("Breeze will prepare the connection first. Then you’ll join the fan’s temporary Wi-Fi hotspot and return here to finish.")
                    } else {
                        Text("Keep your iPhone on the home Wi-Fi network while connecting.")
                    }
                    Toggle(useAPMode ? "The green light blinks slowly and I can see the fan’s Wi-Fi in Settings" : "The green light blinks rapidly", isOn: $isReady)
                        .disabled(connection.isPairing)
                }
                Section {
                    if connection.pairingProgress.stage != .idle {
                        PairingStatusView(progress: connection.pairingProgress)
                    }
                    if connection.isPairing {
                        if connection.isReadyForHotspot {
                            Text("Stay on the fan’s Wi-Fi even if iOS says No Internet. Breeze cannot verify the network name in this build; this button is your confirmation.")
                            Button("I’ve joined the fan’s Wi-Fi") {
                                connection.continueAfterJoiningHotspot()
                                password = ""
                            }
                        } else if connection.isReadyForHomeWiFi {
                            Button("I’m back on my home Wi-Fi") {
                                connection.continueAfterReturningHome()
                            }
                        }
                        Button("Stop connecting", role: .cancel) { connection.stopPairing() }
                    } else {
                        Button("Connect fan") {
                            connection.startPairing(ssid: ssid, password: password, useAPMode: useAPMode)
                            password = ""
                        }
                        .disabled(ssid.isEmpty || !isReady || (!useAPMode && !connection.supportsEZPairing) || connection.isBusy)
                    }
                    if let error = connection.errorMessage {
                        Text(error).font(.footnote).foregroundStyle(.red)
                    }
                    if connection.message == "Fan connected." {
                        Label("Fan connected", systemImage: "checkmark.circle")
                        Button("View my fans") { dismiss() }
                    }
                }
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: connection.isPairing)
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: connection.isReadyForHotspot)
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: useAPMode)
            .navigationTitle("Add fan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingGuide) {
                NavigationStack {
                    PairingGuideView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { showingGuide = false }
                            }
                        }
                }
            }
            .onDisappear {
                connection.stopPairing()
                password = ""
            }
            .task { wifi.detect() }
            .onChange(of: wifi.isChecking) { _, checking in
                // Never replace a manually entered name or the home network during AP pairing.
                guard !checking, !connection.isPairing else { return }
                if !wifi.name.isEmpty && (ssid.isEmpty || useDetectedNetwork) { ssid = wifi.name }
                useDetectedNetwork = false
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { connection.checkPairingDeadline() }
                if phase == .active && !connection.isPairing { wifi.detect() }
            }
            .onChange(of: useAPMode) { _, _ in isReady = false }
        }
    }
}
