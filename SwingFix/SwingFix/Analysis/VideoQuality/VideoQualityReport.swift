import Foundation

struct VideoQualityReport: Hashable {
    enum Severity: Int, Comparable, Hashable {
        case good = 0
        case warning = 1
        case critical = 2

        static func < (
            lhs: Severity,
            rhs: Severity
        ) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    enum Category: Hashable {
        case recordingQuality
        case cameraSetup
        case system
    }

    struct Finding: Identifiable, Hashable {
        let id: UUID
        let title: String
        let message: String
        let severity: Severity
        let category: Category
        let systemImage: String

        init(
            id: UUID = UUID(),
            title: String,
            message: String,
            severity: Severity,
            category: Category,
            systemImage: String
        ) {
            self.id = id
            self.title = title
            self.message = message
            self.severity = severity
            self.category = category
            self.systemImage = systemImage
        }
    }

    let score: Int
    let findings: [Finding]

    var canContinue: Bool {
        !findings.contains {
            $0.severity == .critical
        }
    }

    var summary: String {
        switch score {
        case 100:
            return "Excellent recording setup"

        case 85..<100:
            return "Great recording setup"

        case 65..<85:
            return "Usable with a few improvements"

        default:
            return "A new recording is recommended"
        }
    }

    var pointsNeeded: Int {
        max(100 - score, 0)
    }

    var recordingFindings: [Finding] {
        findings.filter {
            $0.category == .recordingQuality
        }
    }

    var cameraFindings: [Finding] {
        findings.filter {
            $0.category == .cameraSetup
        }
    }

    var systemFindings: [Finding] {
        findings.filter {
            $0.category == .system
        }
    }

    var improvementFindings: [Finding] {
        findings.filter {
            $0.severity == .warning ||
            $0.severity == .critical
        }
    }
}
