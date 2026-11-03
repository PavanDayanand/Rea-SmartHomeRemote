import SwiftUI

struct BreezeHomeTabs: View {
    @Environment(HomeConnection.self) private var connection
    @State private var selection = "home"
    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house", value: "home") { ConnectedHomeView() }
            Tab("Settings", systemImage: "gearshape", value: "settings") { BreezeSettingsView() }
        }
        .onChange(of: connection.navigationRequest) { _, _ in selection = "home" }
    }
}
