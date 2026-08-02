import SwiftUI

struct PlaybackTimelineView: View {
    @Binding var currentTime: Double
    let duration: Double
    let accentColor: Color
    let onSeek: (Double) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(formatTime(currentTime))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(minWidth: 40, alignment: .leading)

            Slider(
                value: Binding(
                    get: {
                        min(currentTime, duration)
                    },
                    set: { newValue in
                        currentTime = newValue
                        onSeek(newValue)
                    }
                ),
                in: 0...max(duration, 0.1)
            )
            .tint(accentColor)

            Text(formatTime(duration))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(minWidth: 40, alignment: .trailing)
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else {
            return "0:00"
        }

        let totalSeconds = Int(seconds.rounded(.down))
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60

        return String(
            format: "%d:%02d",
            minutes,
            remainingSeconds
        )
    }
}
