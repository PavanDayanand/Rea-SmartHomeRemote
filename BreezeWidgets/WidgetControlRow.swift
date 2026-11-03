import SwiftUI

struct WidgetControlRow: View {
    let fanID: String
    let control: WidgetFanControl
    var roomy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(control.name, systemImage: control.symbol).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 5) {
                ForEach(Array(control.choices.prefix(6)), id: \.self) { choice in
                    Button(intent: ControlConnectedFanIntent(deviceID: fanID, action: "control:" + control.id, value: choice)) {
                        Text(choice.replacingOccurrences(of: "_", with: " "))
                            .font(.caption2.weight(.semibold)).lineLimit(1).minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity, minHeight: roomy ? 44 : 28)
                    }
                    .buttonStyle(.plain)
                    .background(control.value == choice ? Color.teal.opacity(0.25) : Color.secondary.opacity(0.15), in: .capsule)
                    .foregroundStyle(control.value == choice ? .teal : .primary)
                    .accessibilityLabel("\(control.name), \(choice)")
                }
            }
        }
    }
}
