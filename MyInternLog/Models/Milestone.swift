import Foundation
import SwiftData

enum MilestoneType: String, CaseIterable {
    case internshipStart
    case internshipEnd
    case mentorMeeting
    case evaluation
    case reportDue
    case presentation
    case schoolDeadline

    var label: String {
        switch self {
        case .internshipStart: return "Internship Start"
        case .internshipEnd: return "Internship End"
        case .mentorMeeting: return "Mentor Meeting"
        case .evaluation: return "Evaluation"
        case .reportDue: return "Report Due"
        case .presentation: return "Presentation"
        case .schoolDeadline: return "School Deadline"
        }
    }
}

@Model
final class Milestone {
    var id: UUID
    var title: String
    var date: Date
    var typeRawValue: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    var type: MilestoneType {
        get { MilestoneType(rawValue: typeRawValue) ?? .presentation }
        set { typeRawValue = newValue.rawValue }
    }

    init(title: String, date: Date, type: MilestoneType, notes: String = "") {
        self.id = UUID()
        self.title = title
        self.date = date
        self.typeRawValue = type.rawValue
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
