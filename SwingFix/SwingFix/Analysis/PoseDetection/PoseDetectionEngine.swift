import AVFoundation
import CoreGraphics
import Foundation
import ImageIO
import Vision

struct PoseDetectionEngine {
    private let frameSampler = VideoFrameSampler()

    func processVideo(
        at videoURL: URL,
        samplesPerSecond: Double = 4,
        minimumConfidence: Float = 0.3
    ) async -> PoseSequence {
        let asset = AVURLAsset(url: videoURL)

        let durationTime = try? await asset.load(.duration)
        let duration = durationTime?.seconds ?? 0

        guard duration.isFinite, duration > 0 else {
            return PoseSequence(
                videoDuration: 0,
                requestedSampleRate: samplesPerSecond,
                frames: [],
                processedFrameCount: 0,
                failedFrameCount: 0
            )
        }

        let sampledFrames: [SampledVideoFrame]

        do {
            sampledFrames = try await frameSampler.sampleFrames(
                from: asset,
                duration: duration,
                samplesPerSecond: samplesPerSecond
            )
        } catch {
            print("Video frame sampling failed:", error)

            return PoseSequence(
                videoDuration: duration,
                requestedSampleRate: samplesPerSecond,
                frames: [],
                processedFrameCount: 0,
                failedFrameCount: 0
            )
        }

        var poseFrames: [PoseFrame] = []
        var failedFrameCount = 0

        for sampledFrame in sampledFrames {
            do {
                if let poseFrame = try detectPose(
                    in: sampledFrame.image,
                    timestamp: sampledFrame.timestamp,
                    minimumConfidence: minimumConfidence
                ) {
                    poseFrames.append(poseFrame)
                } else {
                    failedFrameCount += 1
                }
            } catch {
                failedFrameCount += 1

                print(
                    "Pose detection failed at",
                    sampledFrame.timestamp,
                    error
                )
            }
        }

        return PoseSequence(
            videoDuration: duration,
            requestedSampleRate: samplesPerSecond,
            frames: poseFrames,
            processedFrameCount: sampledFrames.count,
            failedFrameCount: failedFrameCount
        )
    }

    private func detectPose(
        in image: CGImage,
        timestamp: Double,
        minimumConfidence: Float
    ) throws -> PoseFrame? {
        let request = VNDetectHumanBodyPoseRequest()

        let handler = VNImageRequestHandler(
            cgImage: image,
            orientation: .up,
            options: [:]
        )

        try handler.perform([request])

        guard let observation = request.results?.first else {
            return nil
        }

        var joints: [BodyJoint.Name: BodyJoint] = [:]

        for jointName in BodyJoint.Name.allCases {
            guard let point = try? observation.recognizedPoint(
                jointName.visionName
            ) else {
                continue
            }

            guard point.confidence >= minimumConfidence else {
                continue
            }

            joints[jointName] = BodyJoint(
                name: jointName,
                location: point.location,
                confidence: point.confidence
            )
        }

        guard !joints.isEmpty else {
            return nil
        }

        return PoseFrame(
            timestamp: timestamp,
            joints: joints,
            imageSize: CGSize(
                width: image.width,
                height: image.height
            )
        )
    }
}
