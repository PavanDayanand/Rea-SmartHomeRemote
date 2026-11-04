import SwiftUI

@main
struct BreezeApp: App {
    // @State keeps one store alive as SwiftUI redraws the interface.
    @State private var connection = HomeConnection.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if ProcessInfo.processInfo.arguments.contains("--controls-preview") {
                    ConnectedHomeView(previewDeviceID: "preview")
                } else if ProcessInfo.processInfo.arguments.contains("--pairing-preview") {
                    // A disconnected screen for UI checks; it never simulates activation.
                    AddFanView()
                } else {
                    BreezeHomeTabs()
                }
            }
                .environment(connection)
                .tint(.teal)
                .onOpenURL { url in
                    guard url.scheme == "breeze", url.host == "connected" else { return }
                    connection.requestedDeviceID = url.lastPathComponent
                    connection.navigationRequest = UUID()
                    let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
                    connection.handleWidgetCommand(deviceID: url.lastPathComponent,
                        action: query?.first(where: { $0.name == "action" })?.value,
                        value: query?.first(where: { $0.name == "value" })?.value)
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        // The fan's AP hotspot has no internet. Do not start a cloud
                        // home refresh when returning from Settings during pairing.
                        if connection.isPairing {
                            connection.checkPairingDeadline()
                        } else {
                            connection.run { try await connection.loadHome() }
                        }
                    }
                }
                .task { BreezeShortcuts.updateAppShortcutParameters() }
        }
    }
}
