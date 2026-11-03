import SwiftUI

struct PairingGuideView: View {
    var body: some View {
        List {
            Section {
                Image("OrientRemote")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .accessibilityLabel("Orient remote: FS+ at the top, Timer on the right, FS− at the bottom; light and power buttons below.")
            }
            Section("Remote steps · fast blinking") {
                Text("These are the EZ instructions from your Orient app screenshots.")
                    .foregroundStyle(.secondary)
                Label("1. Turn the fan and light off using the remote.", systemImage: "power")
                Label("2. Press FS− until the remote displays 1.", systemImage: "minus.circle")
                Label("3. Press Timer until the remote displays 8.", systemImage: "timer")
                Label("4. Press FS+, then Timer, then FS− in that order. Check for a rapidly blinking green indicator.", systemImage: "arrow.right.circle")
            }
            Section("Use AP mode in this build") {
                Text("Fast blinking is EZ mode. This build cannot send the EZ broadcast required by iOS, so fast blinking alone will not connect it.")
                Text("For AP mode, use the fan’s manufacturer instructions to switch to slow blinking. Check Settings → Wi-Fi for the fan’s temporary network. The screenshots supplied do not show the remote sequence for switching to AP mode.")
                Text("If no temporary fan network appears, don’t tap the hotspot confirmation. Return to the fan’s AP setup instructions first.")
            }
            Section("Connect in Breeze") {
                Text("1. While the phone is on your home Wi-Fi, enter its exact name and password. Use a 2.4 GHz network.")
                Text("2. Confirm slow blinking and a visible fan hotspot, then tap Connect fan. Wait for ‘Join the fan’s Wi-Fi’.")
                Text("3. Open Settings → Wi-Fi. Join the fan’s temporary network, even if it says No Internet. Return to Breeze and tap ‘I’ve joined the fan’s Wi-Fi’.")
                Text("4. Keep Breeze open and allow Local Network access. If Breeze asks you to return to home Wi-Fi, do that and confirm. Wait for activation confirmation.")
            }
        }
        .navigationTitle("Remote pairing guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}
