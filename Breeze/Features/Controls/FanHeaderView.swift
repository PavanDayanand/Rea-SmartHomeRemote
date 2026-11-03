import SwiftUI

struct FanHeaderView: View {
    let fan: Fan

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "fan.ceiling.fill")
                .font(.largeTitle.scaled(by: 1.6))
                .foregroundStyle(fan.isOn ? .teal : .secondary)
                .frame(width: 120, height: 120)
                .background(.teal.opacity(0.08), in: .circle)
                .accessibilityHidden(true)
            Text(fan.room).font(.headline)
            Text(fan.isOn ? "A little breeze, just for you." : "A quiet moment.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 16)
    }
}
