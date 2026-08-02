import CoreGraphics
import Foundation
import Vision

struct BodyJoint: Identifiable, Hashable, Sendable {
    enum Name: String, CaseIterable, Identifiable, Hashable, Sendable {
        case nose
        case neck

        case leftShoulder
        case rightShoulder
        case leftElbow
        case rightElbow
        case leftWrist
        case rightWrist

        case root
        case leftHip
        case rightHip
        case leftKnee
        case rightKnee
        case leftAnkle
        case rightAnkle

        case leftEar
        case rightEar
        case leftEye
        case rightEye

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .nose:
                return "Nose"

            case .neck:
                return "Neck"

            case .leftShoulder:
                return "Left Shoulder"

            case .rightShoulder:
                return "Right Shoulder"

            case .leftElbow:
                return "Left Elbow"

            case .rightElbow:
                return "Right Elbow"

            case .leftWrist:
                return "Left Wrist"

            case .rightWrist:
                return "Right Wrist"

            case .root:
                return "Pelvis"

            case .leftHip:
                return "Left Hip"

            case .rightHip:
                return "Right Hip"

            case .leftKnee:
                return "Left Knee"

            case .rightKnee:
                return "Right Knee"

            case .leftAnkle:
                return "Left Ankle"

            case .rightAnkle:
                return "Right Ankle"

            case .leftEar:
                return "Left Ear"

            case .rightEar:
                return "Right Ear"

            case .leftEye:
                return "Left Eye"

            case .rightEye:
                return "Right Eye"
            }
        }

        var visionName: VNHumanBodyPoseObservation.JointName {
            switch self {
            case .nose:
                return .nose

            case .neck:
                return .neck

            case .leftShoulder:
                return .leftShoulder

            case .rightShoulder:
                return .rightShoulder

            case .leftElbow:
                return .leftElbow

            case .rightElbow:
                return .rightElbow

            case .leftWrist:
                return .leftWrist

            case .rightWrist:
                return .rightWrist

            case .root:
                return .root

            case .leftHip:
                return .leftHip

            case .rightHip:
                return .rightHip

            case .leftKnee:
                return .leftKnee

            case .rightKnee:
                return .rightKnee

            case .leftAnkle:
                return .leftAnkle

            case .rightAnkle:
                return .rightAnkle

            case .leftEar:
                return .leftEar

            case .rightEar:
                return .rightEar

            case .leftEye:
                return .leftEye

            case .rightEye:
                return .rightEye
            }
        }
    }

    let name: Name
    let location: CGPoint
    let confidence: Float

    var id: Name {
        name
    }

    func isReliable(
        minimumConfidence: Float = 0.3
    ) -> Bool {
        confidence >= minimumConfidence
    }
}
