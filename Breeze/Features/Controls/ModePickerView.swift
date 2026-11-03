import SwiftUI

struct ModePickerView: View {
    let fanID: String
    @Environment(FanStore.self) private var store

    var body: some View {
        List {
            Section {
                ForEach(FanMode.allCases) { mode in
                    Button {
                        store.perform { try store.setMode(id: fanID, mode: mode) }
                    } label: {
                        HStack {
                            Label(mode.rawValue, systemImage: mode.symbol)
                                .foregroundStyle(.primary)
                            Spacer()
                            if store.fan(id: fanID)?.mode == mode {
                                Image(systemName: "checkmark").foregroundStyle(.teal)
                            }
                        }
                        .frame(minHeight: 32)
                    }
                    .accessibilityAddTraits(store.fan(id: fanID)?.mode == mode ? .isSelected : [])
                }
            } footer: {
                Text("These are the modes shown in your existing fan app. This preview saves your selection without operating the fan.")
            }
        }
        .navigationTitle("Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}
