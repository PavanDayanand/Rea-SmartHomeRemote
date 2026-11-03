import SwiftUI

struct SpeedControlView: View {
    let fan: Fan
    @Environment(FanStore.self) private var store

    var body: some View {
        // Adaptive columns wrap at large text sizes instead of shrinking labels.
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 10) {
            ForEach(1...fan.speedCount, id: \.self) { speed in
                Button {
                    store.perform { try store.setSpeed(id: fan.id, speed: speed) }
                } label: {
                    VStack(spacing: 3) {
                        Text(speed, format: .number).font(.headline)
                        Image(systemName: fan.speed == speed ? "checkmark" : "minus")
                            .font(.caption2)
                            .opacity(fan.speed == speed ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
                .tint(fan.speed == speed ? .teal : .secondary)
                .accessibilityLabel("Speed \(speed)")
                .accessibilityAddTraits(fan.speed == speed ? .isSelected : [])
                .accessibilityIdentifier("speed.\(speed)")
            }
        }
        .padding(.vertical, 4)
    }
}
