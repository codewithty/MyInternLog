import Foundation
import SwiftData
@testable import MyInternLog

// Builds a throwaway in-memory SwiftData store so tests can create real
// model objects (and relationships between them) without touching disk.
@MainActor
func makeTestContext() throws -> ModelContext {
    let schema = Schema([
        QuickNote.self, StudyItem.self, Reflection.self, ReflectionAnswer.self,
        AttachmentItem.self, DailyLog.self, InternshipProfile.self, Milestone.self,
        ReminderSetting.self, CareerOutput.self, Tag.self, KnowledgeItem.self,
        ProjectGroup.self, WeeklyRecap.self
    ])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [config])
    return ModelContext(container)
}

// A fixed calendar/date so date-based tests never depend on today's date.
enum TestCalendar {
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.firstWeekday = 1 // Sunday
        return calendar
    }

    static func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
