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

enum MilestoneReminderOption: String, CaseIterable {
    case none
    case exactDate
    case dayBefore
    case weekBefore

    var label: String {
        switch self {
        case .none: return "No Reminder"
        case .exactDate: return "On the Day"
        case .dayBefore: return "Day Before"
        case .weekBefore: return "Week Before"
        }
    }

    func fireDate(for milestoneDate: Date, calendar: Calendar = .current) -> Date? {
        switch self {
        case .none: return nil
        case .exactDate: return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: milestoneDate)
        case .dayBefore:
            guard let day = calendar.date(byAdding: .day, value: -1, to: milestoneDate) else { return nil }
            return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: day)
        case .weekBefore:
            guard let day = calendar.date(byAdding: .day, value: -7, to: milestoneDate) else { return nil }
            return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: day)
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
    var reminderOptionRawValue: String?
    var createdAt: Date
    var updatedAt: Date

    var type: MilestoneType {
        get { MilestoneType(rawValue: typeRawValue) ?? .presentation }
        set { typeRawValue = newValue.rawValue }
    }

    var reminderOption: MilestoneReminderOption? {
        get { reminderOptionRawValue.flatMap { MilestoneReminderOption(rawValue: $0) } }
        set { reminderOptionRawValue = newValue?.rawValue }
    }

    init(title: String, date: Date, type: MilestoneType, notes: String = "") {
        self.id = UUID()
        self.title = title
        self.date = date
        self.typeRawValue = type.rawValue
        self.notes = notes
        self.reminderOptionRawValue = MilestoneReminderOption.none.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
