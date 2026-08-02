import SwiftUI

struct PlaybackControlsView: View {
    @Binding var isPlaying: Bool
    @Binding var playbackRate: Float
    @Binding var currentTime: Double

    let duration: Double

    let onPlayPause: () -> Void
    let onReplay: () -> Void
    let onPreviousFrame: () -> Void
    let onNextFrame: () -> Void
    let onSeek: (Double) -> Void
    let onRateChanged: () -> Void

    var body: some View {
        VStack(spacing: 16) {

            PlaybackTimelineView(
                currentTime: $currentTime,
                duration: duration,
                accentColor: AppColors.accent,
                onSeek: onSeek
            )

            HStack(spacing: 28) {

                controlButton(
                    systemImage: "backward.frame.fill",
                    action: onPreviousFrame
                )

                controlButton(
                    systemImage: "arrow.counterclockwise",
                    action: onReplay
                )

                Button(action: onPlayPause) {
                    Image(
                        systemName: isPlaying
                        ? "pause.circle.fill"
                        : "play.circle.fill"
                    )
                    .font(.system(size: 54))
                    .foregroundStyle(AppColors.accent)
                }
                .buttonStyle(.plain)

                controlButton(
                    systemImage: "forward.frame.fill",
                    action: onNextFrame
                )
            }

            Picker(
                "Playback Speed",
                selection: $playbackRate
            ) {
                Text("0.25×").tag(Float(0.25))
                Text("0.5×").tag(Float(0.5))
                Text("1×").tag(Float(1.0))
            }
            .pickerStyle(.segmented)
            .onChange(of: playbackRate) {
                onRateChanged()
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }

    private func controlButton(
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2)
        }
        .buttonStyle(.plain)
    }
}
