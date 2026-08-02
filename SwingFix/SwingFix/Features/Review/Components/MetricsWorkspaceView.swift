import SwiftUI

struct MetricsWorkspaceView: View {
    let poseSequence: PoseSequence?
    let isProcessingPose: Bool

    var body: some View {
        VStack(spacing: 20) {
            poseEngineCard
            upcomingMetricsCard
        }
    }

    private var poseEngineCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "figure.golf")
                    .foregroundStyle(AppColors.accent)

                Text("Pose Engine")
                    .font(.title3.bold())

                Spacer()

                statusView
            }

            Divider()

            metricRow(
                title: "Frames Sampled",
                value: "\(poseSequence?.processedFrameCount ?? 0)"
            )

            metricRow(
                title: "Frames With Pose",
                value: "\(poseSequence?.detectedFrameCount ?? 0)"
            )

            metricRow(
                title: "Detection Rate",
                value: "\(Int((poseSequence?.detectionRate ?? 0) * 100))%"
            )

            metricRow(
                title: "Average Joints",
                value: String(
                    format: "%.1f",
                    poseSequence?.averageJointCount ?? 0
                )
            )

            metricRow(
                title: "Pose Quality",
                value: poseQuality
            )

            if !isProcessingPose,
               poseSequence?.isUsable != true {
                Text(
                    "A clearer video or physical iPhone may be required for reliable measurements."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }

    @ViewBuilder
    private var statusView: some View {
        if isProcessingPose {
            ProgressView()
        } else {
            Label(
                poseSequence?.isUsable == true
                    ? "Ready"
                    : "Limited",
                systemImage: poseSequence?.isUsable == true
                    ? "checkmark.circle.fill"
                    : "exclamationmark.triangle.fill"
            )
            .font(.caption.weight(.semibold))
            .foregroundStyle(
                poseSequence?.isUsable == true
                    ? Color.green
                    : Color.orange
            )
        }
    }

    private var upcomingMetricsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Coming Next")
                .font(.headline)

            upcomingMetric("Shoulder Turn")
            upcomingMetric("Hip Rotation")
            upcomingMetric("Spine Angle")
            upcomingMetric("Head Movement")
            upcomingMetric("Weight Shift")
            upcomingMetric("Tempo")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }

    private func metricRow(
        title: String,
        value: String
    ) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.headline)
        }
    }

    private func upcomingMetric(
        _ title: String
    ) -> some View {
        Label(title, systemImage: "circle.dotted")
            .foregroundStyle(.secondary)
    }

    private var poseQuality: String {
        guard let poseSequence else {
            return isProcessingPose
                ? "Analyzing"
                : "Unavailable"
        }

        switch poseSequence.detectionRate {
        case 0.90...:
            return "Excellent"
        case 0.75..<0.90:
            return "Good"
        case 0.50..<0.75:
            return "Fair"
        case 0.25..<0.50:
            return "Limited"
        default:
            return "Poor"
        }
    }
}
