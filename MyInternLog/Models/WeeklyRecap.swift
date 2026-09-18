import Foundation
import SwiftData

@Model
final class WeeklyRecap {
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

    init(weekStartDate: Date, weekEndDate: Date) {
        self.id = UUID()
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.title = ""
        self.selfSummary = ""
        self.aiSummary = ""
        self.nextWeekFocus = ""
        self.isComplete = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    static func findOrCreate(weekOf date: Date, in context: ModelContext) -> WeeklyRecap {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .weekOfYear, for: date) ?? DateInterval(start: date, duration: 604_800)
        let start = interval.start
        let descriptor = FetchDescriptor<WeeklyRecap>(predicate: #Predicate { $0.weekStartDate == start })
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let recap = WeeklyRecap(weekStartDate: start, weekEndDate: interval.end)
        context.insert(recap)
        return recap
    }
}
