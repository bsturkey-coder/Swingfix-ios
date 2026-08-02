import Foundation

struct SwingTimeline: Hashable {
    struct Marker: Identifiable, Hashable {
        let phase: SwingPhase
        let time: Double

        var id: SwingPhase {
            phase
        }
    }

    let duration: Double
    let markers: [Marker]

    func marker(for phase: SwingPhase) -> Marker? {
        markers.first { $0.phase == phase }
    }
}
