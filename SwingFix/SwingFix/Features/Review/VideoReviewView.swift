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
    @State private var poseSequence: PoseSequence?
    @State private var isProcessingPose = false
    @State private var swingTimeline: SwingTimeline?
    @State private var selectedPhase: SwingPhase?
    @State private var selectedWorkspace: ReviewWorkspace = .coach

    private let phaseDetector = SwingPhaseDetector()
    private let coachingEngine = CoachingEngine()
    private let poseDetectionEngine = PoseDetectionEngine()

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

                    ReviewWorkspaceView(
                        selectedWorkspace: $selectedWorkspace,
                        selectedPhase: selectedPhase ?? .address,
                        recommendations: coachingEngine.recommendations(
                            for: selectedPhase ?? .address
                        ),
                        poseSequence: poseSequence,
                        isProcessingPose: isProcessingPose
                    )
                }
                .padding()
                .padding(.bottom, 24)
            }
            .background(AppColors.pageBackground)
        }
        .navigationTitle("Review Swing")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await configurePlayer()
            await processPoseSequence()
        }
        .onDisappear {
            cleanUpPlayer()
        }
    }

    // MARK: - Playback controls

    private var playbackControls: some View {

        PlaybackControlsView(
            isPlaying: $isPlaying,
            playbackRate: $playbackRate,
            currentTime: $currentTime,
            duration: duration,
            onPlayPause: togglePlayback,
            onReplay: replay,
            onPreviousFrame: {
                stepFrame(by: -1)
            },
            onNextFrame: {
                stepFrame(by: 1)
            },
            onSeek: { newTime in
                selectedPhase = nearestPhase(to: newTime)
                seek(to: newTime)
            },
            onRateChanged: updatePlaybackRate
        )
    }

    private var playbackTimeline: some View {
        PlaybackTimelineView(
            currentTime: $currentTime,
            duration: duration,
            accentColor: AppColors.accent
        ) { newTime in
            selectedPhase = nearestPhase(to: newTime)
            seek(to: newTime)
        }
    }

   
    // MARK: - Review workspace

    
    // MARK: - Player setup

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
    @MainActor
    private func processPoseSequence() async {
        isProcessingPose = true

        poseSequence = await poseDetectionEngine.processVideo(
            at: video.url,
            samplesPerSecond: 4
        )

        isProcessingPose = false
    }
    
    private func selectSwingPosition(
        _ marker: SwingTimeline.Marker
    ) {
        player.pause()
        isPlaying = false
        selectedPhase = marker.phase
        selectedWorkspace = .coach
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
                currentTime = 0
                seek(to: 0)
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
        player.currentItem?.step(
            byCount: frameCount
        )
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
