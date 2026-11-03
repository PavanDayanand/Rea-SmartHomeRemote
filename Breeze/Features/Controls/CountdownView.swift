import SwiftUI

struct CountdownView: View {
    let fanID: String
    @Environment(FanStore.self) private var store

    var body: some View {
        List {
            if let date = store.fan(id: fanID)?.turnsOffAt {
                Section {
                    LabeledContent("Demo fan turns off") { Text(date, style: .time) }
                    Button("Cancel timer", role: .destructive) { setTimer(hours: 0) }
                }
            }

            Section("Turn off after") {
                ForEach([2, 4, 6, 8], id: \.self) { hours in
                    Button("\(hours) hours") { setTimer(hours: hours) }
                        .disabled(store.fan(id: fanID)?.isOn != true)
                }
            }

            Section {
                Text("Turn the demo fan on before setting a timer. Demo timers update while Breeze is open or the next time it refreshes. They do not run your real fan in the background.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Sleep timer")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func setTimer(hours: Int) {
        store.perform { try store.setCountdown(id: fanID, hours: hours) }
    }
}
