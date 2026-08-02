import AVFoundation
import CoreGraphics
import Foundation

struct FrameExtractor {
    enum FrameExtractionError: LocalizedError {
        case invalidDuration
        case unableToGenerateFrame

        var errorDescription: String? {
            switch self {
            case .invalidDuration:
                return "The video duration could not be determined."

            case .unableToGenerateFrame:
                return "SwingFix could not extract a usable video frame."
            }
        }
    }

    func representativeFrame(
        from asset: AVAsset,
        duration: Double
    ) async throws -> CGImage {
        guard duration.isFinite, duration > 0 else {
            throw FrameExtractionError.invalidDuration
        }

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = CMTime(
            seconds: 0.1,
            preferredTimescale: 600
        )
        generator.requestedTimeToleranceAfter = CMTime(
            seconds: 0.1,
            preferredTimescale: 600
        )

        let sampleSeconds = min(
            max(duration * 0.35, 0.25),
            max(duration - 0.1, 0)
        )

        let sampleTime = CMTime(
            seconds: sampleSeconds,
            preferredTimescale: 600
        )

        do {
            let result = try await generator.image(at: sampleTime)
            return result.image
        } catch {
            print("Frame extraction failed:", error)
            throw FrameExtractionError.unableToGenerateFrame
        }
    }
}
