import SwiftUI

struct RemoteControlTile: View {
    let control: DeviceControl
    let isExpanded: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            VStack(spacing: 8) {
                Image(systemName: control.symbol).font(.title3).foregroundStyle(.teal)
                Text(control.kind == "value" ? String(control.numberValue) : control.label(for: control.textValue))
                    .font(.headline).lineLimit(1).minimumScaleFactor(0.8)
                Text(control.displayName).font(.caption2).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 94)
            .background(isExpanded ? Color.teal.opacity(0.12) : Color.secondary.opacity(0.08), in: .rect(cornerRadius: 20))
            .overlay { if isExpanded { RoundedRectangle(cornerRadius: 20).strokeBorder(.teal.opacity(0.5), lineWidth: 1) } }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Adjust \(control.displayName), \(control.textValue)")
        .accessibilityIdentifier("remote.control.\(control.id)")
        .accessibilityAddTraits(isExpanded ? .isSelected : [])
    }
}
