import Foundation

struct CoachingEngine {
    func recommendations(
        for phase: SwingPhase
    ) -> [CoachingRecommendation] {
        switch phase {
        case .address:
            return [
                CoachingRecommendation(
                    phase: .address,
                    category: .setup,
                    title: "Build a balanced setup",
                    message: "Keep your pressure centered through the middle of both feet with a slight athletic knee flex.",
                    whyItMatters: "A stable setup makes it easier to rotate without losing posture or balance.",
                    priority: .high,
                    confidence: 70
                ),
                CoachingRecommendation(
                    phase: .address,
                    category: .setup,
                    title: "Create room for the arms",
                    message: "Let your arms hang naturally instead of reaching excessively toward the ball.",
                    whyItMatters: "Natural arm spacing encourages a more repeatable takeaway and better contact.",
                    priority: .medium,
                    confidence: 65
                )
            ]

        case .takeaway:
            return [
                CoachingRecommendation(
                    phase: .takeaway,
                    category: .backswing,
                    title: "Start the club with your chest",
                    message: "Move the hands, arms, and chest together during the first part of the takeaway.",
                    whyItMatters: "A connected takeaway helps prevent the club from getting too far inside or outside early.",
                    priority: .high,
                    confidence: 70
                ),
                CoachingRecommendation(
                    phase: .takeaway,
                    category: .backswing,
                    title: "Keep the clubhead outside the hands",
                    message: "At the early takeaway, avoid pulling the club sharply behind your body.",
                    whyItMatters: "This supports a more neutral swing plane and reduces compensations later.",
                    priority: .medium,
                    confidence: 60
                )
            ]

        case .top:
            return [
                CoachingRecommendation(
                    phase: .top,
                    category: .backswing,
                    title: "Maintain width",
                    message: "Keep space between your hands and trail shoulder rather than collapsing the arms.",
                    whyItMatters: "Better width gives you more room to sequence the downswing and control the clubface.",
                    priority: .high,
                    confidence: 70
                ),
                CoachingRecommendation(
                    phase: .top,
                    category: .transition,
                    title: "Finish the turn before starting down",
                    message: "Allow the backswing turn to complete before aggressively moving the arms toward the ball.",
                    whyItMatters: "A patient transition improves sequencing and can reduce an over-the-top move.",
                    priority: .medium,
                    confidence: 65
                )
            ]

        case .impact:
            return [
                CoachingRecommendation(
                    phase: .impact,
                    category: .impact,
                    title: "Keep rotating through impact",
                    message: "Continue turning your chest and hips through the strike instead of stopping at the ball.",
                    whyItMatters: "Continued rotation supports solid contact, speed, and a stable clubface.",
                    priority: .high,
                    confidence: 75
                ),
                CoachingRecommendation(
                    phase: .impact,
                    category: .impact,
                    title: "Maintain posture",
                    message: "Keep your hips back and avoid standing up through the hitting area.",
                    whyItMatters: "Maintaining posture gives the arms room to deliver the club consistently.",
                    priority: .high,
                    confidence: 70
                )
            ]

        case .finish:
            return [
                CoachingRecommendation(
                    phase: .finish,
                    category: .finish,
                    title: "Hold a balanced finish",
                    message: "Finish with most of your pressure on the lead side and your body facing the target.",
                    whyItMatters: "A balanced finish is a useful sign that the swing remained coordinated and controlled.",
                    priority: .high,
                    confidence: 75
                ),
                CoachingRecommendation(
                    phase: .finish,
                    category: .finish,
                    title: "Let the motion fully complete",
                    message: "Avoid abruptly stopping the arms or body immediately after contact.",
                    whyItMatters: "A complete follow-through supports speed and reduces tension through the strike.",
                    priority: .medium,
                    confidence: 65
                )
            ]
        }
    }
}
