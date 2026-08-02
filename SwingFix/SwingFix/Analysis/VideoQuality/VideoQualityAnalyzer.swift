import AVFoundation
import CoreGraphics
import Foundation

struct VideoQualityAnalyzer {
    private let frameExtractor = FrameExtractor()
    private let poseDetector = BodyPoseDetector()

    func analyze(
        videoURL: URL
    ) async -> VideoQualityReport {
        let asset = AVURLAsset(url: videoURL)

        guard let track = try? await asset
            .loadTracks(withMediaType: .video)
            .first else {
            return unreadableVideoReport
        }

        let durationTime = try? await asset.load(.duration)
        let duration = durationTime?.seconds ?? 0

        let naturalSize = try? await track.load(.naturalSize)
        let preferredTransform = try? await track.load(
            .preferredTransform
        )
        let frameRate = try? await track.load(
            .nominalFrameRate
        )

        let videoSize = resolvedVideoSize(
            naturalSize: naturalSize ?? .zero,
            transform: preferredTransform ?? .identity
        )

        var score = 100
        var findings: [VideoQualityReport.Finding] = []

        evaluateMetadata(
            duration: duration,
            videoSize: videoSize,
            frameRate: frameRate ?? 0,
            score: &score,
            findings: &findings
        )

        #if targetEnvironment(simulator)
        findings.append(
            .init(
                title: "Advanced Camera Check",
                message: "Pose-based framing analysis will run when SwingFix is installed on a physical iPhone.",
                severity: .good,
                category: .system,
                systemImage: "iphone"
            )
        )
        #else
        do {
            let frame = try await frameExtractor
                .representativeFrame(
                    from: asset,
                    duration: duration
                )

            let pose = try poseDetector.detectPose(
                in: frame
            )

            evaluatePose(
                pose,
                score: &score,
                findings: &findings
            )
        } catch {
            print("Body-pose check failed:", error)

            findings.append(
                .init(
                    title: "Camera Check Unavailable",
                    message: "SwingFix could not complete pose-based framing analysis for this recording.",
                    severity: .good,
                    category: .system,
                    systemImage: "figure.golf"
                )
            )
        }
        #endif

        if findings.isEmpty {
            findings.append(
                .init(
                    title: "Recording Looks Good",
                    message: "The video meets the initial checks and is ready for swing analysis.",
                    severity: .good,
                    category: .recordingQuality,
                    systemImage: "checkmark.circle.fill"
                )
            )
        }

        return VideoQualityReport(
            score: max(score, 0),
            findings: findings.sorted {
                $0.severity > $1.severity
            }
        )
    }

    private var unreadableVideoReport: VideoQualityReport {
        VideoQualityReport(
            score: 0,
            findings: [
                .init(
                    title: "Video Could Not Be Read",
                    message: "Please select another recording.",
                    severity: .critical,
                    category: .recordingQuality,
                    systemImage: "xmark.octagon.fill"
                )
            ]
        )
    }

    private func evaluateMetadata(
        duration: Double,
        videoSize: CGSize,
        frameRate: Float,
        score: inout Int,
        findings: inout [VideoQualityReport.Finding]
    ) {
        let shortestDimension = min(
            videoSize.width,
            videoSize.height
        )

        if shortestDimension < 720 {
            score -= 15

            findings.append(
                .init(
                    title: "Low Resolution",
                    message: "Record in at least 720p. Using 1080p or higher will improve body-position analysis.",
                    severity: .warning,
                    category: .recordingQuality,
                    systemImage: "rectangle.badge.exclamationmark"
                )
            )
        }

        if frameRate > 0, frameRate < 30 {
            score -= 15

            findings.append(
                .init(
                    title: "Low Frame Rate",
                    message: "Record at 30 fps or higher. Slow-motion video is best for impact analysis.",
                    severity: .warning,
                    category: .recordingQuality,
                    systemImage: "film"
                )
            )
        } else if frameRate >= 30, frameRate < 60 {
            score -= 5

            findings.append(
                .init(
                    title: "Higher Frame Rate Recommended",
                    message: "Recording at 60 fps or higher will make frame-by-frame review clearer.",
                    severity: .good,
                    category: .recordingQuality,
                    systemImage: "speedometer"
                )
            )
        }

        if duration < 2 {
            score -= 35

            findings.append(
                .init(
                    title: "Clip Too Short",
                    message: "Include the complete swing from setup through the finish.",
                    severity: .critical,
                    category: .recordingQuality,
                    systemImage: "timer"
                )
            )
        } else if duration > 30 {
            score -= 5

            findings.append(
                .init(
                    title: "Long Recording",
                    message: "Trim the video so the swing is faster and easier to analyze.",
                    severity: .good,
                    category: .recordingQuality,
                    systemImage: "scissors"
                )
            )
        }
    }

    private func evaluatePose(
        _ pose: BodyPoseResult,
        score: inout Int,
        findings: inout [VideoQualityReport.Finding]
    ) {
        let bounds = pose.boundingBox
        let centerOffset = abs(bounds.midX - 0.5)

        if bounds.height < 0.35 {
            score -= 20

            findings.append(
                .init(
                    title: "Move the Camera Closer",
                    message: "The golfer is too small in the frame. Move closer while keeping the full body and club visible.",
                    severity: .warning,
                    category: .cameraSetup,
                    systemImage: "arrow.up.left.and.arrow.down.right"
                )
            )
        } else if bounds.height > 0.88 ||
                    bounds.width > 0.85 {
            score -= 25

            findings.append(
                .init(
                    title: "Move the Camera Farther Away",
                    message: "Move back so the golfer and full swing remain inside the frame.",
                    severity: .critical,
                    category: .cameraSetup,
                    systemImage: "arrow.down.right.and.arrow.up.left"
                )
            )
        }

        if centerOffset > 0.14 {
            score -= 12

            findings.append(
                .init(
                    title: "Recenter the Golfer",
                    message: bounds.midX < 0.5
                        ? "Point the camera slightly farther left."
                        : "Point the camera slightly farther right.",
                    severity: .warning,
                    category: .cameraSetup,
                    systemImage: "viewfinder"
                )
            )
        }

        if !pose.headVisible {
            score -= 15

            findings.append(
                .init(
                    title: "Keep the Head Visible",
                    message: "Move the camera back or adjust its angle so the golfer’s head remains visible.",
                    severity: .warning,
                    category: .cameraSetup,
                    systemImage: "person.crop.circle.badge.exclamationmark"
                )
            )
        }

        if !pose.bothFeetVisible {
            score -= 20

            findings.append(
                .init(
                    title: "Keep Both Feet Visible",
                    message: "Move the camera back or lower it so both feet remain visible throughout the swing.",
                    severity: .critical,
                    category: .cameraSetup,
                    systemImage: "shoeprints.fill"
                )
            )
        }

        if bounds.minX < 0.03 ||
            bounds.maxX > 0.97 {
            score -= 12

            findings.append(
                .init(
                    title: "Leave More Side-to-Side Space",
                    message: "Give the golfer enough room for the backswing and follow-through.",
                    severity: .warning,
                    category: .cameraSetup,
                    systemImage: "rectangle.center.inset.filled"
                )
            )
        }

        if bounds.height >= 0.35,
           bounds.height <= 0.88,
           centerOffset <= 0.14,
           pose.headVisible,
           pose.bothFeetVisible {
            findings.append(
                .init(
                    title: "Golfer Framing Looks Good",
                    message: "The golfer is centered and the key body points are visible.",
                    severity: .good,
                    category: .cameraSetup,
                    systemImage: "figure.golf"
                )
            )
        }
    }

    private func resolvedVideoSize(
        naturalSize: CGSize,
        transform: CGAffineTransform
    ) -> CGSize {
        let transformedSize = naturalSize.applying(
            transform
        )

        return CGSize(
            width: abs(transformedSize.width),
            height: abs(transformedSize.height)
        )
    }
}
