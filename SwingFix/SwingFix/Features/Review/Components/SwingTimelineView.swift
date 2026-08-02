import SwiftUI

struct SwingTimelineView: View {
    let timeline: SwingTimeline
    let selectedPhase: SwingPhase?
    let onSelect: (SwingTimeline.Marker) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Swing Positions")
                    .font(.title3.bold())

                Spacer()

                Text("Estimated")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(timeline.markers) { marker in
                        Button {
                            onSelect(marker)
                        } label: {
                            VStack(spacing: 8) {
                                Image(
                                    systemName: marker.phase.systemImage
                                )
                                .font(.headline)

                                Text(marker.phase.title)
                                    .font(.caption.weight(.semibold))

                                Text(formatTime(marker.time))
                                    .font(.caption2.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 86, height: 88)
                            .background(
                                selectedPhase == marker.phase
                                    ? AppColors.accent.opacity(0.18)
                                    : AppColors.cardBackground
                            )
                            .foregroundStyle(
                                selectedPhase == marker.phase
                                    ? AppColors.accent
                                    : .primary
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 16,
                                    style: .continuous
                                )
                            )
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: 16,
                                    style: .continuous
                                )
                                .stroke(
                                    selectedPhase == marker.phase
                                        ? AppColors.accent
                                        : Color.clear,
                                    lineWidth: 2
                                )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Text(
                "These positions are estimated from the clip length. Automatic pose-based detection will replace them in a future release."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds.rounded())
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60

        return String(
            format: "%d:%02d",
            minutes,
            remainingSeconds
        )
    }
}
