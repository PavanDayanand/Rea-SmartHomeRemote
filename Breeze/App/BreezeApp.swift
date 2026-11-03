import SwiftUI

@main
struct BreezeApp: App {
    // @State keeps one store alive as SwiftUI redraws the interface.
    @State private var widgetDeviceID: String?
    @State private var showingWidgetDevice = false
    @State private var store = FanStore()
    @State private var connection = HomeConnection()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if ProcessInfo.processInfo.arguments.contains("--controls-preview") {
                    NavigationStack { ConnectedDeviceView(deviceID: "preview") }
                } else if ProcessInfo.processInfo.arguments.contains("--pairing-preview") {
                    // A disconnected screen for UI checks; it never simulates activation.
                    AddFanView()
                } else if ProcessInfo.processInfo.arguments.contains("--demo") {
                    HomeView()
                } else {
                    ConnectedHomeView()
                }
            }
                .environment(store)
                .environment(connection)
                .tint(.teal)
                .onOpenURL { url in
                    guard url.scheme == "breeze", url.host == "connected" else { return }
                    widgetDeviceID = url.lastPathComponent
                    showingWidgetDevice = true
                    connection.run { try await connection.loadHome() }
                }
                .sheet(isPresented: $showingWidgetDevice) {
                    NavigationStack {
                        if let widgetDeviceID {
                            ConnectedDeviceView(deviceID: widgetDeviceID)
                                .toolbar {
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button("Done") { showingWidgetDevice = false }
                                    }
                                }
                        }
                    }
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        store.refresh()
                        // The fan's AP hotspot has no internet. Do not start a cloud
                        // home refresh when returning from Settings during pairing.
                        if connection.isPairing {
                            connection.checkPairingDeadline()
                        } else {
                            connection.run { try await connection.loadHome() }
                        }
                    }
                }
                .task {
                    store.refresh()
                    // Demo timers are reconciled while the app is active or next opened.
                    // A real timer must run on the fan or an always-on bridge.
                    while !Task.isCancelled {
                        do {
                            try await Task.sleep(for: .seconds(15))
                        } catch {
                            return
                        }
                        store.refresh()
                    }
                }
        }
    }
}
