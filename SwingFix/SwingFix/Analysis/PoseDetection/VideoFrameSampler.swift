import AVFoundation
import CoreGraphics
import Foundation

struct SampledVideoFrame: Sendable {
    let timestamp: Double
    let image: CGImage
}

struct VideoFrameSampler {
    enum SamplingError: LocalizedError {
        case invalidDuration
        case noFramesGenerated

        var errorDescription: String? {
            switch self {
            case .invalidDuration:
                return "The video duration could not be determined."

            case .noFramesGenerated:
                return "SwingFix could not extract frames from this video."
            }
        }
    }

    func sampleFrames(
        from asset: AVAsset,
        duration: Double,
        samplesPerSecond: Double = 4
    ) async throws -> [SampledVideoFrame] {
        guard duration.isFinite, duration > 0 else {
            throw SamplingError.invalidDuration
        }

        let safeSampleRate = max(samplesPerSecond, 1)
        let interval = 1.0 / safeSampleRate

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = CMTime(
            seconds: 0.05,
            preferredTimescale: 600
        )
        generator.requestedTimeToleranceAfter = CMTime(
            seconds: 0.05,
            preferredTimescale: 600
        )

        var timestamps: [Double] = []
        var currentTime = 0.0

        while currentTime <= duration {
            timestamps.append(currentTime)
            currentTime += interval
        }

        if timestamps.last != duration {
            timestamps.append(duration)
        }

        var frames: [SampledVideoFrame] = []

        for timestamp in timestamps {
            let time = CMTime(
                seconds: min(timestamp, duration),
                preferredTimescale: 600
            )

            do {
                let result = try await generator.image(at: time)

                frames.append(
                    SampledVideoFrame(
                        timestamp: timestamp,
                        image: result.image
                    )
                )
            } catch {
                print(
                    "Frame sampling failed at",
                    timestamp,
                    error
                )
            }
        }

        guard !frames.isEmpty else {
            throw SamplingError.noFramesGenerated
        }

        return frames
    }
}
