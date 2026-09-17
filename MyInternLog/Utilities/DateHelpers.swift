import Foundation

enum DateHelpers {

    // Builds the grid of dates for a month, padded with leading/trailing nils
    // so the result is a whole number of 7-day weeks.
    static func monthGrid(for monthDate: Date, calendar: Calendar = .current) -> [Date?] {
        guard let monthStart = calendar.dateInterval(of: .month, for: monthDate)?.start,
              let dayRange = calendar.range(of: .day, in: .month, for: monthDate) else {
            return []
        }

        let daysInMonth = dayRange.count
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingPadding = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingPadding)
        for offset in 0..<daysInMonth {
            if let day = calendar.date(byAdding: .day, value: offset, to: monthStart) {
                days.append(day)
            }
        }

        let trailingPadding = (7 - days.count % 7) % 7
        days.append(contentsOf: Array(repeating: nil, count: trailingPadding))
        return days
    }

    static func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
}
