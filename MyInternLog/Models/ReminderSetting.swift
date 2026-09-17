import Foundation
import SwiftData

@Model
final class ReminderSetting {
    var id: UUID
    var label: String
    var message: String
    var time: Date
    // 1 = Sunday ... 7 = Saturday, matching Calendar's weekday component.
    var enabledWeekdays: [Int]
    var isEnabled: Bool

    init(label: String, message: String, time: Date, enabledWeekdays: [Int] = Array(1...7), isEnabled: Bool = false) {
        self.id = UUID()
        self.label = label
        self.message = message
        self.time = time
        self.enabledWeekdays = enabledWeekdays
        self.isEnabled = isEnabled
    }

    // Version 1 ships with three default slots, all off until the user opts in.
    static func ensureDefaults(in context: ModelContext) {
        let descriptor = FetchDescriptor<ReminderSetting>()
        guard let existing = try? context.fetch(descriptor), existing.isEmpty else { return }

        let calendar = Calendar.current
        func time(hour: Int, minute: Int) -> Date {
            calendar.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
        }

        let defaults = [
            ReminderSetting(label: "Morning capture", message: "Capture your first note.", time: time(hour: 9, minute: 0)),
            ReminderSetting(label: "Midday learning", message: "Log what you learned so far.", time: time(hour: 14, minute: 0)),
            ReminderSetting(label: "Evening reflection", message: "Write today's reflection.", time: time(hour: 18, minute: 0))
        ]
        for reminder in defaults {
            context.insert(reminder)
        }
    }
}
