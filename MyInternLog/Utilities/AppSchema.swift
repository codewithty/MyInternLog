import SwiftData

// The one list of SwiftData models. The app, demo mode, and the tests all build
// their database from this, so a new model can't be forgotten in one of them.
enum AppSchema {
    static let models: [any PersistentModel.Type] = [
        QuickNote.self, StudyItem.self, Reflection.self, ReflectionAnswer.self,
        AttachmentItem.self, DailyLog.self, InternshipProfile.self, Milestone.self,
        ReminderSetting.self, CareerOutput.self, Tag.self, KnowledgeItem.self,
        ProjectGroup.self, WeeklyRecap.self
    ]

    static var schema: Schema { Schema(models) }

    // The real on-disk store. If it can't open there is nothing safe to fall back
    // to (a fresh empty store would hide the user's data), so stop loudly.
    static func makeRealContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Could not open the MyInternLog database: \(error)")
        }
    }
}
