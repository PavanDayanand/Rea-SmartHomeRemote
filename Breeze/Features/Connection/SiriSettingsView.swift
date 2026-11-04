import SwiftUI
import AppIntents

struct SiriSettingsView: View {
    @Environment(HomeConnection.self) private var connection
    @AppStorage("siri.defaultFanID", store: UserDefaults(suiteName: FanStorage.appGroup)) private var defaultFanID = ""

    var body: some View {
        Form {
            Section("Choose your fan") {
                Picker("Default fan", selection: $defaultFanID) {
                    Text("Ask which fan").tag("")
                    ForEach(connection.devices) { fan in Text(fan.name).tag(fan.id) }
                }
                Text("With one connected fan, Siri selects it automatically. With several, choose a default or name the fan in your command.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Try saying") {
                Text("Hey Siri, turn on the fan in Breeze")
                Text("Hey Siri, increase fan speed in Breeze")
                Text("Hey Siri, decrease fan speed in Breeze")
                Text("Hey Siri, set fan speed in Breeze")
            }
            Section("Your own phrases") {
                ShortcutsLink()
                Text("In Shortcuts, create a shortcut and add a Breeze action. Choose its fan and settings, then name it ‘Turn on Pawan fan’ or ‘Increase speed’. Say that shortcut’s name to Siri.")
                Text("Speed changes use the current device report. Turn the fan on first. The fan’s supported minimum and maximum are respected.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Siri & Shortcuts")
        .onChange(of: defaultFanID) { BreezeShortcuts.updateAppShortcutParameters() }
    }
}
