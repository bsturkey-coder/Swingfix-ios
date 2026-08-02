import Foundation

enum SwingPhase: String, CaseIterable, Identifiable, Hashable {
    case address
    case takeaway
    case top
    case impact
    case finish

    var id: String { rawValue }

    var title: String {
        switch self {
        case .address:
            return "Address"
        case .takeaway:
            return "Takeaway"
        case .top:
            return "Top"
        case .impact:
            return "Impact"
        case .finish:
            return "Finish"
        }
    }

    var systemImage: String {
        switch self {
        case .address:
            return "figure.stand"
        case .takeaway:
            return "arrow.up.right"
        case .top:
            return "arrow.up"
        case .impact:
            return "burst.fill"
        case .finish:
            return "flag.checkered"
        }
    }
}
