import SwiftUI

enum ReviewWorkspace: String, CaseIterable, Identifiable {
    case coach
    case metrics
    case drills

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .coach:
            return "Coach"
        case .metrics:
            return "Metrics"
        case .drills:
            return "Drills"
        }
    }
}

struct ReviewWorkspaceView: View {
    @Binding var selectedWorkspace: ReviewWorkspace

    let selectedPhase: SwingPhase
    let recommendations: [CoachingRecommendation]
    let poseSequence: PoseSequence?
    let isProcessingPose: Bool

    var body: some View {
        VStack(spacing: 16) {
            Picker(
                "Review Workspace",
                selection: $selectedWorkspace
            ) {
                ForEach(ReviewWorkspace.allCases) { workspace in
                    Text(workspace.title)
                        .tag(workspace)
                }
            }
            .pickerStyle(.segmented)

            workspaceContent
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }

    @ViewBuilder
    private var workspaceContent: some View {
        switch selectedWorkspace {
        case .coach:
            CoachWorkspaceView(
                phase: selectedPhase,
                recommendations: recommendations
            )

        case .metrics:
            MetricsWorkspaceView(
                poseSequence: poseSequence,
                isProcessingPose: isProcessingPose
            )

        case .drills:
            DrillsWorkspaceView()
        }
    }
}
