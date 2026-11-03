import SwiftUI

struct LightPickerView: View {
    let fanID: String
    @Environment(FanStore.self) private var store

    var body: some View {
        List {
            Section {
                ForEach(0...3, id: \.self) { level in
                    Button {
                        store.perform { try store.setLight(id: fanID, level: level) }
                    } label: {
                        HStack {
                            Label(level == 0 ? "Off" : "Level \(level)",
                                  systemImage: level == 0 ? "lightbulb.slash" : "lightbulb.fill")
                                .foregroundStyle(.primary)
                            Spacer()
                            if store.fan(id: fanID)?.lightLevel == level {
                                Image(systemName: "checkmark").foregroundStyle(.teal)
                            }
                        }
                        .frame(minHeight: 32)
                    }
                    .accessibilityAddTraits(store.fan(id: fanID)?.lightLevel == level ? .isSelected : [])
                    .accessibilityIdentifier("light.\(level)")
                }
            } footer: {
                Text("Three light levels, matching the controls in your screenshots.")
            }
        }
        .navigationTitle("Light")
        .navigationBarTitleDisplayMode(.inline)
    }
}
