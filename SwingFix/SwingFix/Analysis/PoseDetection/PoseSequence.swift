import Foundation

struct PoseSequence: Hashable, Sendable {
    let videoDuration: Double
    let requestedSampleRate: Double
    let frames: [PoseFrame]
    let processedFrameCount: Int
    let failedFrameCount: Int

    init(
        videoDuration: Double,
        requestedSampleRate: Double,
        frames: [PoseFrame],
        processedFrameCount: Int,
        failedFrameCount: Int
    ) {
        self.videoDuration = videoDuration
        self.requestedSampleRate = requestedSampleRate
        self.frames = frames.sorted {
            $0.timestamp < $1.timestamp
        }
        self.processedFrameCount = processedFrameCount
        self.failedFrameCount = failedFrameCount
    }

    var detectedFrameCount: Int {
        frames.count
    }

    var detectionRate: Double {
        guard processedFrameCount > 0 else {
            return 0
        }

        return Double(detectedFrameCount) /
            Double(processedFrameCount)
    }

    var averageJointCount: Double {
        guard !frames.isEmpty else {
            return 0
        }

        let total = frames.reduce(0) {
            $0 + $1.detectedJointCount
        }

        return Double(total) /
            Double(frames.count)
    }

    var isUsable: Bool {
        detectedFrameCount >= 3 &&
        detectionRate >= 0.25
    }

    func nearestFrame(
        to timestamp: Double
    ) -> PoseFrame? {
        frames.min {
            abs($0.timestamp - timestamp) <
            abs($1.timestamp - timestamp)
        }
    }

    func frames(
        from startTime: Double,
        through endTime: Double
    ) -> [PoseFrame] {
        frames.filter {
            $0.timestamp >= startTime &&
            $0.timestamp <= endTime
        }
    }
}
