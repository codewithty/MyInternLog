import Foundation

// Pure functions so streak/stat logic can be unit tested without SwiftUI or SwiftData.
enum DashboardStats {

    // Consecutive days ending today (or referenceDate) with at least one completed reflection.
    // Missing a day breaks the streak — there is no backfill.
    static func currentStreak(reflections: [Reflection], asOf referenceDate: Date = Date(), calendar: Calendar = .current) -> Int {
        let completedDays = Set(reflections.filter { $0.isComplete }.map { calendar.startOfDay(for: $0.date) })
        var streak = 0
        var day = calendar.startOfDay(for: referenceDate)
        while completedDays.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    static func entryCountsByDay(notes: [QuickNote], lastDays: Int, asOf referenceDate: Date = Date(), calendar: Calendar = .current) -> [(day: Date, count: Int)] {
        let today = calendar.startOfDay(for: referenceDate)
        var counts: [Date: Int] = [:]
        for note in notes {
            counts[calendar.startOfDay(for: note.dateCreated), default: 0] += 1
        }
        return (0..<lastDays).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return (day, counts[day] ?? 0)
        }
    }

    static func winCountsByDay(notes: [QuickNote], lastDays: Int, asOf referenceDate: Date = Date(), calendar: Calendar = .current) -> [(day: Date, count: Int)] {
        entryCountsByDay(
            notes: notes.filter { $0.tag == .win || $0.highlightType == .win },
            lastDays: lastDays,
            asOf: referenceDate,
            calendar: calendar
        )
    }

    // Streak, as a per-day 1/0 series, so it can be charted like the other trends.
    static func streakSeriesByDay(reflections: [Reflection], lastDays: Int, asOf referenceDate: Date = Date(), calendar: Calendar = .current) -> [(day: Date, completed: Bool)] {
        let completedDays = Set(reflections.filter { $0.isComplete }.map { calendar.startOfDay(for: $0.date) })
        let today = calendar.startOfDay(for: referenceDate)
        return (0..<lastDays).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return (day, completedDays.contains(day))
        }
    }

    // Mood/confidence/energy/stress trend for a metric, skipping days with no value set.
    static func moodTrend(logs: [DailyLog], keyPath: KeyPath<DailyLog, Int?>, lastDays: Int, asOf referenceDate: Date = Date(), calendar: Calendar = .current) -> [(day: Date, value: Int)] {
        var valuesByDay: [Date: Int] = [:]
        for log in logs {
            if let value = log[keyPath: keyPath] {
                valuesByDay[calendar.startOfDay(for: log.date)] = value
            }
        }
        let today = calendar.startOfDay(for: referenceDate)
        return (0..<lastDays).reversed().compactMap { offset -> (Date, Int)? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today),
                  let value = valuesByDay[day] else { return nil }
            return (day, value)
        }
    }
}
