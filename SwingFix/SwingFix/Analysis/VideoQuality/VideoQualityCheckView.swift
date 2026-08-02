import AVFoundation
import SwiftUI

struct VideoQualityCheckView: View {
    let video: ImportedVideo

    @State private var report: VideoQualityReport?
    @State private var thumbnail: CGImage?
    @State private var isAnalyzing = true

    private let analyzer = VideoQualityAnalyzer()
    private let frameExtractor = FrameExtractor()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                if let thumbnail {
                    thumbnailView(thumbnail)
                }

                if isAnalyzing {
                    analyzingView
                } else if let report {
                    scoreCard(report)

                    improvementSection(report)

                    findingsSection(
                        title: "Recording Quality",
                        findings: report.recordingFindings
                    )

                    findingsSection(
                        title: "Camera Recommendations",
                        findings: report.cameraFindings
                    )

                    findingsSection(
                        title: "Analysis Availability",
                        findings: report.systemFindings
                    )

                    continueButton(report)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.visible)
        .background(AppColors.pageBackground)
        .navigationTitle("Video Check")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await analyzeVideo()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Before we analyze your swing")
                .font(.title2.bold())

            Text(
                "SwingFix checks the recording and camera setup before generating coaching feedback."
            )
            .foregroundStyle(.secondary)
        }
    }

    private func thumbnailView(
        _ image: CGImage
    ) -> some View {
        Image(
            decorative: image,
            scale: 1
        )
        .resizable()
        .scaledToFit()
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 280)
        .background(.black)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }

    private var analyzingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)

            Text("Checking your recording…")
                .font(.headline)

            Text(
                "Reviewing resolution, frame rate, clip length, and golfer positioning."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }

    private func scoreCard(
        _ report: VideoQualityReport
    ) -> some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(
                        Color.secondary.opacity(0.18),
                        lineWidth: 14
                    )

                Circle()
                    .trim(
                        from: 0,
                        to: CGFloat(report.score) / 100
                    )
                    .stroke(
                        scoreColor(report.score),
                        style: StrokeStyle(
                            lineWidth: 14,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(report.score)")
                        .font(
                            .system(
                                size: 46,
                                weight: .bold,
                                design: .rounded
                            )
                        )

                    Text("/ 100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 150, height: 150)

            VStack(spacing: 5) {
                Text("Video Quality Score")
                    .font(.headline)

                Text(report.summary)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(AppColors.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }

    @ViewBuilder
    private func improvementSection(
        _ report: VideoQualityReport
    ) -> some View {
        if report.score < 100 {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    Text("How to Reach 100")
                        .font(.title3.bold())

                    Spacer()

                    Text("\(report.pointsNeeded) points available")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                if report.improvementFindings.isEmpty {
                    improvementRow(
                        title: "Complete the camera check",
                        message: "Run SwingFix on a physical iPhone to complete pose-based framing checks.",
                        systemImage: "iphone"
                    )
                } else {
                    ForEach(report.improvementFindings) { finding in
                        improvementRow(
                            title: finding.title,
                            message: improvementMessage(
                                for: finding
                            ),
                            systemImage: "arrow.up.circle.fill"
                        )
                    }
                }
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(AppColors.cardBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
        }
    }

    private func improvementRow(
        title: String,
        message: String,
        systemImage: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(AppColors.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
    }

    @ViewBuilder
    private func findingsSection(
        title: String,
        findings: [VideoQualityReport.Finding]
    ) -> some View {
        if !findings.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.title3.bold())

                ForEach(findings) { finding in
                    findingCard(finding)
                }
            }
        }
    }

    private func findingCard(
        _ finding: VideoQualityReport.Finding
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: finding.systemImage)
                .font(.title2)
                .foregroundStyle(
                    color(for: finding.severity)
                )
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 5) {
                Text(finding.title)
                    .font(.headline)

                Text(finding.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(AppColors.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }

    private func continueButton(
        _ report: VideoQualityReport
    ) -> some View {
        NavigationLink {
            VideoReviewView(video: video)
        } label: {
            Label(
                report.canContinue
                    ? "Continue to Swing Review"
                    : "Review This Video Anyway",
                systemImage: "arrow.right.circle.fill"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(
            report.canContinue
                ? AppColors.accent
                : .orange
        )
        .padding(.top, 4)
    }

    private func improvementMessage(
        for finding: VideoQualityReport.Finding
    ) -> String {
        switch finding.title {
        case "Low Resolution":
            return "Record at 1080p or higher."

        case "Low Frame Rate":
            return "Record at 60 fps or use the iPhone slow-motion setting."

        case "Higher Frame Rate Recommended":
            return "Switch from 30 fps to 60 fps or higher."

        case "Clip Too Short":
            return "Include setup, the full swing, and a short pause after the finish."

        case "Long Recording":
            return "Trim the clip to roughly 5–10 seconds."

        case "Move the Camera Closer":
            return "Move closer while keeping the golfer, both feet, and the full club visible."

        case "Move the Camera Farther Away":
            return "Move back until the full swing stays inside the frame."

        case "Recenter the Golfer":
            return "Place the golfer near the horizontal center of the frame."

        case "Keep the Head Visible":
            return "Move back or adjust the camera angle so the golfer’s head remains visible."

        case "Keep Both Feet Visible":
            return "Lower the camera or move farther back until both feet remain visible."

        case "Leave More Side-to-Side Space":
            return "Leave enough space for the backswing and follow-through."

        default:
            return finding.message
        }
    }

    private func scoreColor(
        _ score: Int
    ) -> Color {
        switch score {
        case 85...:
            return .green

        case 65..<85:
            return .orange

        default:
            return .red
        }
    }

    private func color(
        for severity: VideoQualityReport.Severity
    ) -> Color {
        switch severity {
        case .good:
            return .green

        case .warning:
            return .orange

        case .critical:
            return .red
        }
    }

    @MainActor
    private func analyzeVideo() async {
        isAnalyzing = true

        let asset = AVURLAsset(url: video.url)

        let durationTime = try? await asset.load(
            .duration
        )

        let duration = durationTime?.seconds ?? 0

        thumbnail = try? await frameExtractor
            .representativeFrame(
                from: asset,
                duration: duration
            )

        report = await analyzer.analyze(
            videoURL: video.url
        )

        isAnalyzing = false
    }
}
