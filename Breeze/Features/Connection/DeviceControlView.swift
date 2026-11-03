import SwiftUI

/// Buttons send the fan's exact reported values; display labels never change the command.
struct DeviceControlView: View {
    let deviceID: String
    let control: DeviceControl
    @Environment(HomeConnection.self) private var connection

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if control.kind == "bool" {
                Toggle(isOn: Binding(get: { control.boolValue }, set: { send($0) })) {
                    Label(control.displayName, systemImage: control.symbol)
                        .font(.headline)
                }
            } else {
                Label(control.displayName, systemImage: control.symbol)
                    .font(.headline)
                switch control.kind {
                case "enum":
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 10) {
                        ForEach(control.choices, id: \.self) { choice in
                            Button { send(choice) } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: control.symbol(for: choice)).font(.title3)
                                    Text(control.label(for: choice)).font(.subheadline.weight(.semibold))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, minHeight: 66)
                                .padding(6)
                            }
                            .buttonStyle(.bordered)
                            .tint(control.textValue == choice ? .teal : .secondary)
                            .accessibilityLabel("\(control.displayName), \(control.label(for: choice))")
                            .accessibilityAddTraits(control.textValue == choice ? .isSelected : [])
                        }
                    }
                case "value":
                    Stepper(value: Binding(get: { control.numberValue }, set: { send($0) }),
                            in: control.minimum...max(control.minimum, control.maximum), step: control.step) {
                        Text(control.numberValue, format: .number).monospacedDigit()
                    }
                default:
                    Text(control.textValue).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .disabled(!control.isWritable)
    }

    private func send(_ value: Any) {
        connection.run {
            try await connection.setValue(deviceID: deviceID, controlID: control.id, value: value)
        }
    }
}
