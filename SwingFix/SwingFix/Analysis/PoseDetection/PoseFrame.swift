import CoreGraphics
import Foundation

struct PoseFrame: Identifiable, Hashable, Sendable {
    let id: UUID
    let timestamp: Double
    let joints: [BodyJoint.Name: BodyJoint]
    let imageSize: CGSize

    init(
        id: UUID = UUID(),
        timestamp: Double,
        joints: [BodyJoint.Name: BodyJoint],
        imageSize: CGSize
    ) {
        self.id = id
        self.timestamp = timestamp
        self.joints = joints
        self.imageSize = imageSize
    }

    var detectedJointCount: Int {
        joints.count
    }

    func joint(
        _ name: BodyJoint.Name,
        minimumConfidence: Float = 0.3
    ) -> BodyJoint? {
        guard let joint = joints[name],
              joint.isReliable(
                minimumConfidence: minimumConfidence
              ) else {
            return nil
        }

        return joint
    }

    func contains(
        _ name: BodyJoint.Name,
        minimumConfidence: Float = 0.3
    ) -> Bool {
        joint(
            name,
            minimumConfidence: minimumConfidence
        ) != nil
    }

    func point(
        for name: BodyJoint.Name,
        minimumConfidence: Float = 0.3
    ) -> CGPoint? {
        joint(
            name,
            minimumConfidence: minimumConfidence
        )?.location
    }

    func boundingBox(
        minimumConfidence: Float = 0.3
    ) -> CGRect? {
        let reliablePoints = joints.values
            .filter {
                $0.isReliable(
                    minimumConfidence: minimumConfidence
                )
            }
            .map(\.location)

        guard
            let minimumX = reliablePoints.map(\.x).min(),
            let maximumX = reliablePoints.map(\.x).max(),
            let minimumY = reliablePoints.map(\.y).min(),
            let maximumY = reliablePoints.map(\.y).max()
        else {
            return nil
        }

        return CGRect(
            x: minimumX,
            y: minimumY,
            width: maximumX - minimumX,
            height: maximumY - minimumY
        )
    }
}
