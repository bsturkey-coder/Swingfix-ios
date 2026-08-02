import AVKit
import SwiftUI

struct VideoReviewView: View {
    let video: ImportedVideo

    @State private var player: AVPlayer
    @State private var isPlaying = false
    @State private var currentTime = 0.0
    @State private var duration = 1.0
    @State private var playbackRate: Float = 1.0
    @State private var timeObserverToken: Any?
    @State private var endObserverToken: NSObjectProtocol?

    @State private var swingTimeline: SwingTimeline?
    @State private var selectedPhase: SwingPhase?

    private let phaseDetector = SwingPhaseDetector()

    init(video: ImportedVideo) {
        self.video = video
        _player = State(
            initialValue: AVPlayer(url: video.url)
        )
    }

    var body: some View {
        GeometryReader { geometry in
            let playerHeight = responsivePlayerHeight(
                for: geometry.size
            )

            ScrollView {
                VStack(spacing: 18) {
                    VideoPlayer(player: player)
                        .frame(maxWidth: .infinity)
                        .frame(height: playerHeight)
                        .background(.black)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 20,
                                style: .continuous
                            )
                        )

                    playbackControls

                    if let swingTimeline {
                        SwingTimelineView(
                            timeline: swingTimeline,
                            selectedPhase: selectedPhase
                        ) { marker in
                            selectSwingPosition(marker)
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
                }
                .padding()
                .padding(.bottom, 20)
            }
            .background(AppColors.pageBackground)
        }
        .navigationTitle("Review Swing")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await configurePlayer()
        }
        .onDisappear {
            cleanUpPlayer()
        }
    }

    private var playbackControls: some View {
        VStack(spacing: 16) {
            playbackTimeline

            HStack(spacing: 28) {
                frameButton(
                    systemImage: "backward.frame.fill",
                    accessibilityLabel: "Previous frame"
                ) {
                    stepFrame(by: -1)
                }

                controlButton(
                    systemImage: "arrow.counterclockwise",
                    accessibilityLabel: "Replay swing"
                ) {
                    replay()
                }

                Button {
                    togglePlayback()
                } label: {
                    Image(
                        systemName: isPlaying
                            ? "pause.circle.fill"
                            : "play.circle.fill"
                    )
                    .font(.system(size: 54))
                    .foregroundStyle(AppColors.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    isPlaying
                        ? "Pause video"
                        : "Play video"
                )

                frameButton(
                    systemImage: "forward.frame.fill",
                    accessibilityLabel: "Next frame"
                ) {
                    stepFrame(by: 1)
                }
            }
            .frame(maxWidth: .infinity)

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
                updatePlaybackRate()
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

    private var playbackTimeline: some View {
        HStack(spacing: 12) {
            Text(formatTime(currentTime))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(
                    minWidth: 34,
                    alignment: .leading
                )

            Slider(
                value: Binding(
                    get: {
                        min(currentTime, duration)
                    },
                    set: { newValue in
                        currentTime = newValue
                        selectedPhase = nearestPhase(
                            to: newValue
                        )
                        seek(to: newValue)
                    }
                ),
                in: 0...max(duration, 0.1)
            )
            .tint(AppColors.accent)

            Text(formatTime(duration))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(
                    minWidth: 34,
                    alignment: .trailing
                )
        }
    }

    private func frameButton(
        systemImage: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func controlButton(
        systemImage: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    @MainActor
    private func configurePlayer() async {
        guard let currentItem = player.currentItem else {
            return
        }

        do {
            let loadedDuration = try await currentItem.asset.load(
                .duration
            )

            duration = loadedDuration.seconds.isFinite
                ? loadedDuration.seconds
                : 1.0
        } catch {
            duration = 1.0
        }

        swingTimeline = phaseDetector.detect(
            duration: duration
        )

        selectedPhase = swingTimeline?
            .markers
            .first?
            .phase

        addTimeObserver()
        addPlaybackEndObserver(for: currentItem)
    }

    private func selectSwingPosition(
        _ marker: SwingTimeline.Marker
    ) {
        player.pause()
        isPlaying = false
        selectedPhase = marker.phase
        currentTime = marker.time
        seek(to: marker.time)
    }

    private func nearestPhase(
        to time: Double
    ) -> SwingPhase? {
        guard let markers = swingTimeline?.markers,
              !markers.isEmpty else {
            return nil
        }

        return markers.min {
            abs($0.time - time) <
            abs($1.time - time)
        }?.phase
    }

    private func togglePlayback() {
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            if currentTime >= duration {
                seek(to: 0)
                currentTime = 0
            }

            player.playImmediately(
                atRate: playbackRate
            )

            isPlaying = true
        }
    }

    private func replay() {
        selectedPhase = swingTimeline?
            .markers
            .first?
            .phase

        currentTime = 0
        seek(to: 0)

        player.playImmediately(
            atRate: playbackRate
        )

        isPlaying = true
    }

    private func seek(
        to seconds: Double
    ) {
        let clampedSeconds = min(
            max(seconds, 0),
            duration
        )

        let time = CMTime(
            seconds: clampedSeconds,
            preferredTimescale: 600
        )

        player.seek(
            to: time,
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }

    private func stepFrame(
        by frameCount: Int
    ) {
        player.pause()
        isPlaying = false

        player.currentItem?
            .step(byCount: frameCount)
    }

    private func updatePlaybackRate() {
        guard isPlaying else {
            return
        }

        player.rate = playbackRate
    }

    private func addTimeObserver() {
        removeTimeObserver()

        let interval = CMTime(
            seconds: 0.05,
            preferredTimescale: 600
        )

        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { time in
            let seconds = time.seconds.isFinite
                ? time.seconds
                : 0

            currentTime = seconds
            isPlaying = player.rate > 0

            if isPlaying {
                selectedPhase = nearestPhase(
                    to: seconds
                )
            }
        }
    }

    private func addPlaybackEndObserver(
        for item: AVPlayerItem
    ) {
        removePlaybackEndObserver()

        endObserverToken = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            isPlaying = false
            currentTime = duration
            selectedPhase = .finish
        }
    }

    private func removeTimeObserver() {
        guard let timeObserverToken else {
            return
        }

        player.removeTimeObserver(
            timeObserverToken
        )

        self.timeObserverToken = nil
    }

    private func removePlaybackEndObserver() {
        guard let endObserverToken else {
            return
        }

        NotificationCenter.default.removeObserver(
            endObserverToken
        )

        self.endObserverToken = nil
    }

    private func cleanUpPlayer() {
        player.pause()
        isPlaying = false
        removeTimeObserver()
        removePlaybackEndObserver()
    }

    private func responsivePlayerHeight(
        for size: CGSize
    ) -> CGFloat {
        let widthBasedHeight = size.width * 1.05
        let heightBasedLimit = size.height * 0.54

        return min(
            max(widthBasedHeight, 300),
            heightBasedLimit,
            480
        )
    }

    private func formatTime(
        _ seconds: Double
    ) -> String {
        guard seconds.isFinite else {
            return "0:00"
        }

        let totalSeconds = Int(
            seconds.rounded(.down)
        )

        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60

        return String(
            format: "%d:%02d",
            minutes,
            remainingSeconds
        )
    }
}
