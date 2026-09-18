import Foundation
import SwiftData

@Model
final class DailyLog {
    var id: UUID
    var date: Date
    var title: String
    var selfSummary: String
    var aiSummary: String
    // 1-5 scale, optional — the UI never forces the user to set these.
    var moodValue: Int?
    var confidenceValue: Int?
    var energyValue: Int?
    var stressValue: Int?
    var isComplete: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \QuickNote.dailyLog) var quickNotes: [QuickNote]
    @Relationship(deleteRule: .cascade, inverse: \Reflection.dailyLog) var reflections: [Reflection]
    @Relationship(deleteRule: .cascade, inverse: \AttachmentItem.dailyLog) var attachments: [AttachmentItem]

    init(date: Date) {
        self.id = UUID()
        self.date = date
        self.title = ""
        self.selfSummary = ""
        self.aiSummary = ""
        self.moodValue = nil
        self.confidenceValue = nil
        self.energyValue = nil
        self.stressValue = nil
        self.isComplete = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.quickNotes = []
        self.reflections = []
        self.attachments = []
    }

    // One DailyLog per calendar date. Callers pass any Date; this normalizes
    // to start-of-day so multiple notes on the same day share one log.
    static func findOrCreate(for date: Date, in context: ModelContext) -> DailyLog {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date == startOfDay }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let newLog = DailyLog(date: startOfDay)
        context.insert(newLog)
        return newLog
    }
}
