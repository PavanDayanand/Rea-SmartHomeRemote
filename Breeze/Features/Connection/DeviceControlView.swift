import SwiftUI

/// Buttons send the fan's exact reported values; display labels never change the command.
struct DeviceControlView: View {
    let deviceID: String
    let control: DeviceControl
    @Environment(\.dynamicTypeSize) private var textSize
    @Environment(HomeConnection.self) private var connection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                    LazyVGrid(columns: choiceColumns, spacing: 8) {
                        ForEach(control.choices, id: \.self) { choice in
                            Button { send(choice) } label: {
                                VStack(spacing: 6) {
                                    Group {
                                        if control.name.lowercased().contains("speed") {
                                            Text(control.label(for: choice)).font(.headline)
                                        } else {
                                            Image(systemName: control.symbol(for: choice)).font(.body)
                                        }
                                    }
                                    .frame(width: 44, height: 44)
                                    .background(control.textValue == choice ? Color.teal.opacity(0.25) : Color.secondary.opacity(0.12), in: .circle)
                                    .overlay {
                                        if control.textValue == choice {
                                            Circle().strokeBorder(.teal, lineWidth: 2)
                                        }
                                    }
                                    if !control.name.lowercased().contains("speed") {
                                        Text(control.label(for: choice)).font(.caption2)
                                            .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
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
        .padding(.vertical, 4)
        .disabled(!control.isWritable)
    }

    // Equal columns keep four light choices balanced across the full row.
    private var choiceColumns: [GridItem] {
        if textSize.isAccessibilitySize {
            return [GridItem(.adaptive(minimum: 88))]
        }
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: max(1, min(6, control.choices.count)))
    }

    private func send(_ value: Any) {
        connection.run {
            try await connection.setValue(deviceID: deviceID, controlID: control.id, value: value)
        }
    }
}
