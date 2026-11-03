import SwiftUI

struct PairingStatusView: View {
    let progress: PairingProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(progress.stage.title).font(.headline)
                .accessibilityAddTraits(.updatesFrequently)
            Text(progress.detail).font(.subheadline)
            if progress.deadline != nil {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text("Time remaining: \(progress.remainingSeconds(at: context.date)) seconds")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                ProgressView()
            }
            DisclosureGroup("Connection updates") {
                ForEach(Array(progress.events.enumerated()), id: \.offset) { _, event in
                    Label(event, systemImage: "circle.fill")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
