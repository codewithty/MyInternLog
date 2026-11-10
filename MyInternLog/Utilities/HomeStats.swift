import Foundation

// The numbers on Home. Pure functions so they can be unit tested without
// SwiftUI or SwiftData.
enum HomeStats {

    // Notes created in the current calendar week.
    static func notesThisWeek(_ notes: [QuickNote], asOf date: Date = Date(), calendar: Calendar = .current) -> [QuickNote] {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        return notes.filter { week.contains($0.dateCreated) }
    }

    // Same definition of a win as the Dashboard: tagged Win or highlighted as a win.
    static func isWin(_ note: QuickNote) -> Bool {
        note.tag == .win || note.highlightType == .win
    }

    // Consecutive days with at least one note. If nothing is logged yet today,
    // the streak still counts from yesterday, so it doesn't drop to 0 every morning.
    static func captureStreak(_ notes: [QuickNote], asOf date: Date = Date(), calendar: Calendar = .current) -> Int {
        let days = Set(notes.map { calendar.startOfDay(for: $0.dateCreated) })
        var day = calendar.startOfDay(for: date)
        if !days.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }
        var streak = 0
        while days.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }
}
