import CoreGraphics
import Foundation
import ImageIO
import Vision

struct BodyPoseResult {
    let boundingBox: CGRect
    let detectedJointCount: Int
    let headVisible: Bool
    let leftAnkleVisible: Bool
    let rightAnkleVisible: Bool

    var bothFeetVisible: Bool {
        leftAnkleVisible && rightAnkleVisible
    }
}

struct BodyPoseDetector {
    enum DetectionError: LocalizedError {
        case noPoseDetected
        case insufficientJoints

        var errorDescription: String? {
            switch self {
            case .noPoseDetected:
                return "No clear golfer was detected in the selected frame."

            case .insufficientJoints:
                return "The golfer was detected, but too few body points were visible."
            }
        }
    }

    private let minimumConfidence: Float = 0.25
    private let minimumJointCount = 6

    func detectPose(
        in image: CGImage
    ) throws -> BodyPoseResult {
        let request = VNDetectHumanBodyPoseRequest()

        let handler = VNImageRequestHandler(
            cgImage: image,
            orientation: .up,
            options: [:]
        )

        try handler.perform([request])

        guard let observation = request.results?.first else {
            throw DetectionError.noPoseDetected
        }

        let allPoints = try observation.recognizedPoints(.all)

        let confidentPoints = allPoints.filter {
            $0.value.confidence >= minimumConfidence
        }

        guard confidentPoints.count >= minimumJointCount else {
            throw DetectionError.insufficientJoints
        }

        let boundingBox = boundingBox(
            for: Array(confidentPoints.values)
        )

        return BodyPoseResult(
            boundingBox: boundingBox,
            detectedJointCount: confidentPoints.count,
            headVisible: isVisible(
                observation,
                joint: .nose
            ),
            leftAnkleVisible: isVisible(
                observation,
                joint: .leftAnkle
            ),
            rightAnkleVisible: isVisible(
                observation,
                joint: .rightAnkle
            )
        )
    }

    private func isVisible(
        _ observation: VNHumanBodyPoseObservation,
        joint: VNHumanBodyPoseObservation.JointName
    ) -> Bool {
        guard let point = try? observation.recognizedPoint(joint) else {
            return false
        }

        return point.confidence >= minimumConfidence
    }

    private func boundingBox(
        for points: [VNRecognizedPoint]
    ) -> CGRect {
        let xValues = points.map(\.location.x)
        let yValues = points.map(\.location.y)

        guard
            let minimumX = xValues.min(),
            let maximumX = xValues.max(),
            let minimumY = yValues.min(),
            let maximumY = yValues.max()
        else {
            return .zero
        }

        return CGRect(
            x: minimumX,
            y: minimumY,
            width: maximumX - minimumX,
            height: maximumY - minimumY
        )
    }
}
