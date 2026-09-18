import Foundation
import SwiftData

enum ResumeBulletStyle: String, CaseIterable {
    case technical
    case star
    case beginner
    case federal
    case linkedIn

    var label: String {
        switch self {
        case .technical: return "Technical"
        case .star: return "STAR"
        case .beginner: return "Beginner/Student-Friendly"
        case .federal: return "Federal/Government-Friendly"
        case .linkedIn: return "LinkedIn-Friendly"
        }
    }
}

enum CareerOutputType: String, CaseIterable {
    case dailySummary
    case weeklyRecap
    case resumeBullet
    case interviewTalkingPoint
    case linkedInSummary
    case endOfInternshipSummary
    case cunyPresentationPrep

    var label: String {
        switch self {
        case .dailySummary: return "Daily Summary"
        case .weeklyRecap: return "Weekly Recap"
        case .resumeBullet: return "Resume Bullets"
        case .interviewTalkingPoint: return "Interview Talking Points"
        case .linkedInSummary: return "LinkedIn Summary"
        case .endOfInternshipSummary: return "End-of-Internship Summary"
        case .cunyPresentationPrep: return "CUNY Presentation Prep"
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
    var resumeStyleRawValue: String?
    var text: String
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date

    var outputType: CareerOutputType {
        get { CareerOutputType(rawValue: outputTypeRawValue) ?? .dailySummary }
        set { outputTypeRawValue = newValue.rawValue }
    }

    var resumeStyle: ResumeBulletStyle? {
        get { resumeStyleRawValue.flatMap { ResumeBulletStyle(rawValue: $0) } }
        set { resumeStyleRawValue = newValue?.rawValue }
    }

    init(outputType: CareerOutputType, targetRole: String = "", resumeStyle: ResumeBulletStyle? = nil, text: String) {
        self.id = UUID()
        self.outputTypeRawValue = outputType.rawValue
        self.targetRole = targetRole
        self.resumeStyleRawValue = resumeStyle?.rawValue
        self.text = text
        self.isFavorite = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
