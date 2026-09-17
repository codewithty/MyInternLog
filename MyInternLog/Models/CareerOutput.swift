import Foundation
import SwiftData

enum CareerOutputType: String, CaseIterable {
    case dailySummary
    case weeklyRecap
    case resumeBullet
    case interviewTalkingPoint
    case linkedInSummary

    var label: String {
        switch self {
        case .dailySummary: return "Daily Summary"
        case .weeklyRecap: return "Weekly Recap"
        case .resumeBullet: return "Resume Bullets"
        case .interviewTalkingPoint: return "Interview Talking Points"
        case .linkedInSummary: return "LinkedIn Summary"
        }
    }
}

// Stores the AI's pasted-back result, not the prompt that was copied to it —
// the prompt itself is regenerated on demand and never saved.
@Model
final class CareerOutput {
    var id: UUID
    var outputTypeRawValue: String
    var targetRole: String
    var text: String
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date

    var outputType: CareerOutputType {
        get { CareerOutputType(rawValue: outputTypeRawValue) ?? .dailySummary }
        set { outputTypeRawValue = newValue.rawValue }
    }

    init(outputType: CareerOutputType, targetRole: String = "", text: String) {
        self.id = UUID()
        self.outputTypeRawValue = outputType.rawValue
        self.targetRole = targetRole
        self.text = text
        self.isFavorite = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
