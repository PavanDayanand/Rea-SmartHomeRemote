import SwiftUI

struct FanCardView: View {
    let fan: Fan
    @Environment(FanStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            NavigationLink(value: fan.id) {
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "fan.ceiling.fill")
                        .font(.largeTitle)
                        .foregroundStyle(fan.isOn ? .teal : .secondary)
                        .frame(width: 64, height: 64)
                        .background(.teal.opacity(0.08), in: .rect(cornerRadius: 18))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(fan.room).font(.caption).foregroundStyle(.secondary)
                        Text(fan.name).font(.title3.bold()).foregroundStyle(.primary)
                        Text(fan.summary).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("fan.\(fan.id).details")

            Divider()

            HStack(spacing: 12) {
                Label(fan.lightDescription, systemImage: fan.lightLevel == 0 ? "lightbulb" : "lightbulb.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Light, \(fan.lightDescription)")
                Spacer()
                Button(fan.isOn ? "Turn off" : "Turn on", systemImage: "power") {
                    store.perform { try store.setPower(id: fan.id, isOn: !fan.isOn) }
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .accessibilityLabel("\(fan.isOn ? "Turn off" : "Turn on") \(fan.name)")
                .accessibilityIdentifier("fan.\(fan.id).power")
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 24))
    }
}
