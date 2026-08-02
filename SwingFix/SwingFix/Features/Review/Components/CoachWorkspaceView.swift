import SwiftUI

struct CoachWorkspaceView: View {
    let phase: SwingPhase
    let recommendations: [CoachingRecommendation]

    var body: some View {
        CoachingCardView(
            phase: phase,
            recommendations: recommendations
        )
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
