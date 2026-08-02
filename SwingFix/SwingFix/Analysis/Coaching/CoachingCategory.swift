import Foundation

enum CoachingCategory: String, CaseIterable, Identifiable, Hashable {
    case setup
    case backswing
    case transition
    case impact
    case finish

    var id: String { rawValue }

    var title: String {
        switch self {
        case .setup:
            return "Setup"
        case .backswing:
            return "Backswing"
        case .transition:
            return "Transition"
        case .impact:
            return "Impact"
        case .finish:
            return "Finish"
        }
    }

    var systemImage: String {
        switch self {
        case .setup:
            return "figure.stand"
        case .backswing:
            return "arrow.up.right"
        case .transition:
            return "arrow.triangle.2.circlepath"
        case .impact:
            return "burst.fill"
        case .finish:
            return "flag.checkered"
        }
    }
}
