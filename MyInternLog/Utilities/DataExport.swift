import Foundation

// The shape of the "Export All Data" file. Plain Codable structs, so the JSON stays
// readable and doesn't depend on SwiftData. Notes list their tags, skills, and projects
// by name and link to daily logs and attachments by id, so the file reads without
// cross-referencing. Device-local details (like attachment file paths) are left out.
struct DataExport: Codable {
    var app: String
    var formatVersion: Int
    var exportedAt: Date
    var profile: ProfileRecord?
    var notes: [NoteRecord]
    var studyItems: [StudyItemRecord]
    var dailyLogs: [DailyLogRecord]
    var reflections: [ReflectionRecord]
    var attachments: [AttachmentRecord]
    var milestones: [MilestoneRecord]
    var reminders: [ReminderRecord]
    var careerOutputs: [CareerOutputRecord]
    var weeklyRecaps: [WeeklyRecapRecord]
    var tags: [String]
    var skillsAndTools: [SkillRecord]
    var projectGroups: [ProjectGroupRecord]
}

struct ProfileRecord: Codable {
    var title: String
    var organization: String
    var location: String
    var startDate: Date?
    var endDate: Date?
    var presentationDate: Date?
    var mentorName: String
    var mentorEmail: String
    var mentorPhone: String
    var schoolProgram: String
    var notes: String
    var useGenericWordingByDefault: Bool
    var showWeekNumber: Bool
}

struct NoteRecord: Codable {
    var id: UUID
    var title: String
    var body: String
    var dateCreated: Date
    var tag: String
    var highlight: String?
    var tags: [String]
    var skillsAndTools: [String]
    var projectGroups: [String]
    var dailyLogID: UUID?
    var attachmentIDs: [UUID]
}

struct StudyItemRecord: Codable {
    var id: UUID
    var title: String
    var notes: String
    var dateAdded: Date
    var isReviewed: Bool
}

struct DailyLogRecord: Codable {
    var id: UUID
    var date: Date
    var title: String
    var selfSummary: String
    var aiSummary: String
    var mood: Int?
    var confidence: Int?
    var energy: Int?
    var stress: Int?
    var isComplete: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct ReflectionRecord: Codable {
    var id: UUID
    var date: Date
    var template: String
    var isComplete: Bool
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var dailyLogID: UUID?
    var answers: [AnswerRecord]
}

struct AnswerRecord: Codable {
    var prompt: String
    var answer: String
    var order: Int
}

struct AttachmentRecord: Codable {
    var id: UUID
    var fileName: String
    var fileType: String
    var caption: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    var noteID: UUID?
    var dailyLogID: UUID?
}

struct MilestoneRecord: Codable {
    var id: UUID
    var title: String
    var date: Date
    var type: String
    var notes: String
    var reminder: String?
    var createdAt: Date
    var updatedAt: Date
}

struct ReminderRecord: Codable {
    var id: UUID
    var label: String
    var message: String
    var time: Date
    var weekdays: [Int]
    var isEnabled: Bool
    var destination: String
}

struct CareerOutputRecord: Codable {
    var id: UUID
    var type: String
    var targetRole: String
    var resumeStyle: String?
    var text: String
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct WeeklyRecapRecord: Codable {
    var id: UUID
    var weekStartDate: Date
    var weekEndDate: Date
    var title: String
    var selfSummary: String
    var aiSummary: String
    var nextWeekFocus: String
    var isComplete: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct SkillRecord: Codable {
    var name: String
    var category: String
}

struct ProjectGroupRecord: Codable {
    var id: UUID
    var name: String
    var colorName: String
    var iconName: String
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date
}
