import SwiftUI

/// System symbols supply the motion; no timers or custom animation engine needed.
struct FanConnectionHeader: View {
    let title: String
    let subtitle: String
    var isConnecting = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "fan.ceiling.fill")
                .font(.largeTitle)
                .foregroundStyle(.teal)
                .symbolEffect(.rotate, options: .repeating, isActive: isConnecting && !reduceMotion)
                .padding(24)
                .background(.teal.opacity(0.10), in: .circle)
                .accessibilityHidden(true)
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .accessibilityElement(children: .combine)
    }
}
