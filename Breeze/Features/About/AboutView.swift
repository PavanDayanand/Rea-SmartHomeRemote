import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Breeze", systemImage: "fan.ceiling.fill")
                        .font(.title2.bold())
                    Text("Simple controls for a more comfortable home.")
                        .foregroundStyle(.secondary)
                }

                Section("Connection") {
                    LabeledContent("Current home", value: "Demo")
                    Text("Your Orient fans are not connected. Real control needs authenticated access and a verified map of the fan’s commands.")
                    Text("There’s no need to reset your fans. You can keep using Smart Life while we work on the connection.")
                        .foregroundStyle(.secondary)
                }

                Section("Widgets") {
                    Text("Add the Breeze widget from your Home Screen’s widget gallery. Touch and hold it, choose Edit Widget, then select a demo fan.")
                }

                Section("Siri & Shortcuts") {
                    Text("In Shortcuts, add an action and search for Breeze. Choose a demo fan, then set its power, speed, mode, light, or timer.")
                    Text("For a voice phrase you choose, save the action in a shortcut and give that shortcut a name. All actions currently affect demo data only.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("About Breeze")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
