import Foundation

struct SwingPhaseDetector {
    func detect(duration: Double) -> SwingTimeline {
        let safeDuration = max(duration, 0.1)

        let markers: [SwingTimeline.Marker] = [
            .init(
                phase: .address,
                time: safeDuration * 0.12
            ),
            .init(
                phase: .takeaway,
                time: safeDuration * 0.28
            ),
            .init(
                phase: .top,
                time: safeDuration * 0.48
            ),
            .init(
                phase: .impact,
                time: safeDuration * 0.62
            ),
            .init(
                phase: .finish,
                time: safeDuration * 0.86
            )
        ]

        return SwingTimeline(
            duration: safeDuration,
            markers: markers
        )
    }
}
