import Foundation

struct CoachingRecommendation: Identifiable, Hashable {
    enum Priority: Int, Comparable, Hashable {
        case low = 1
        case medium = 2
        case high = 3

        static func < (
            lhs: Priority,
            rhs: Priority
        ) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    let id: UUID
    let phase: SwingPhase
    let category: CoachingCategory
    let title: String
    let message: String
    let whyItMatters: String
    let priority: Priority
    let confidence: Int

    init(
        id: UUID = UUID(),
        phase: SwingPhase,
        category: CoachingCategory,
        title: String,
        message: String,
        whyItMatters: String,
        priority: Priority,
        confidence: Int
    ) {
        self.id = id
        self.phase = phase
        self.category = category
        self.title = title
        self.message = message
        self.whyItMatters = whyItMatters
        self.priority = priority
        self.confidence = min(max(confidence, 0), 100)
    }
}
