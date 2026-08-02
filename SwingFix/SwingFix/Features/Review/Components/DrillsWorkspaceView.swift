import SwiftUI

struct DrillsWorkspaceView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.golf")
                .font(.system(size: 42))
                .foregroundStyle(AppColors.accent)

            Text("Recommended Drills")
                .font(.title3.bold())

            Text(
                "SwingFix will recommend focused practice drills based on your highest-priority coaching feedback."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(AppColors.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }
}
