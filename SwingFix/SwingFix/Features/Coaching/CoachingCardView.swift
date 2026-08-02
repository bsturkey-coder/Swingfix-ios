import SwiftUI

struct CoachingCardView: View {
    let phase: SwingPhase
    let recommendations: [CoachingRecommendation]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            ForEach(recommendations) { recommendation in
                recommendationCard(recommendation)
            }

            Text(
                "These are general coaching cues based on the selected swing phase. Personalized feedback will be added when pose analysis is available."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Coaching Focus")
                    .font(.title3.bold())

                Text(phase.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: phase.systemImage)
                .font(.title2)
                .foregroundStyle(AppColors.accent)
        }
    }

    private func recommendationCard(
        _ recommendation: CoachingRecommendation
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(
                    systemName: recommendation.category.systemImage
                )
                .font(.title3)
                .foregroundStyle(
                    priorityColor(recommendation.priority)
                )
                .frame(width: 28)

                VStack(alignment: .leading, spacing: 5) {
                    Text(recommendation.title)
                        .font(.headline)

                    Text(recommendation.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            VStack(alignment: .leading, spacing: 5) {
                Text("Why it matters")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(recommendation.whyItMatters)
                    .font(.subheadline)
            }

            HStack {
                Label(
                    recommendation.category.title,
                    systemImage: recommendation.category.systemImage
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

                Spacer()

                Text("\(recommendation.confidence)% confidence")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }

    private func priorityColor(
        _ priority: CoachingRecommendation.Priority
    ) -> Color {
        switch priority {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return AppColors.accent
        }
    }
}
