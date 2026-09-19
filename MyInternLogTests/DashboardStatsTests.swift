import XCTest
import SwiftData
@testable import MyInternLog

@MainActor
final class DashboardStatsTests: XCTestCase {
    private let calendar = TestCalendar.calendar

    private func reflection(on date: Date, complete: Bool, in context: ModelContext) -> Reflection {
        let reflection = Reflection(date: date, templateName: "Quick")
        reflection.isComplete = complete
        context.insert(reflection)
        return reflection
    }

    func testStreakCountsConsecutiveCompletedDaysEndingToday() throws {
        let context = try makeTestContext()
        let today = TestCalendar.date(2026, 6, 10)
        let reflections = [
            reflection(on: TestCalendar.date(2026, 6, 10), complete: true, in: context),
            reflection(on: TestCalendar.date(2026, 6, 9), complete: true, in: context),
            reflection(on: TestCalendar.date(2026, 6, 8), complete: true, in: context)
        ]
        XCTAssertEqual(DashboardStats.currentStreak(reflections: reflections, asOf: today, calendar: calendar), 3)
    }

    func testMissingADayBreaksTheStreak() throws {
        let context = try makeTestContext()
        let today = TestCalendar.date(2026, 6, 10)
        let reflections = [
            reflection(on: TestCalendar.date(2026, 6, 10), complete: true, in: context),
            // June 9 missing
            reflection(on: TestCalendar.date(2026, 6, 8), complete: true, in: context)
        ]
        XCTAssertEqual(DashboardStats.currentStreak(reflections: reflections, asOf: today, calendar: calendar), 1)
    }

    func testDraftReflectionsDoNotCountTowardStreak() throws {
        let context = try makeTestContext()
        let today = TestCalendar.date(2026, 6, 10)
        let reflections = [
            reflection(on: TestCalendar.date(2026, 6, 10), complete: false, in: context),
            reflection(on: TestCalendar.date(2026, 6, 9), complete: true, in: context)
        ]
        XCTAssertEqual(DashboardStats.currentStreak(reflections: reflections, asOf: today, calendar: calendar), 0)
    }

    func testStreakIsZeroWithNoReflections() {
        XCTAssertEqual(DashboardStats.currentStreak(reflections: [], asOf: TestCalendar.date(2026, 6, 10), calendar: calendar), 0)
    }

    func testEntryCountsByDayCoversRequestedWindowOldestFirst() throws {
        let context = try makeTestContext()
        let today = TestCalendar.date(2026, 6, 10)
        let noteToday = QuickNote(title: "a")
        noteToday.dateCreated = TestCalendar.date(2026, 6, 10, hour: 9)
        let noteTodayToo = QuickNote(title: "b")
        noteTodayToo.dateCreated = TestCalendar.date(2026, 6, 10, hour: 15)
        let noteTwoDaysAgo = QuickNote(title: "c")
        noteTwoDaysAgo.dateCreated = TestCalendar.date(2026, 6, 8)
        [noteToday, noteTodayToo, noteTwoDaysAgo].forEach(context.insert)

        let counts = DashboardStats.entryCountsByDay(
            notes: [noteToday, noteTodayToo, noteTwoDaysAgo], lastDays: 3, asOf: today, calendar: calendar
        )

        XCTAssertEqual(counts.count, 3)
        XCTAssertEqual(counts.map(\.count), [1, 0, 2]) // June 8, 9, 10
    }

    func testWinCountsIncludeWinTagAndWinHighlight() throws {
        let context = try makeTestContext()
        let today = TestCalendar.date(2026, 6, 10)
        let tagged = QuickNote(title: "tagged", tag: .win)
        tagged.dateCreated = today
        let highlighted = QuickNote(title: "highlighted")
        highlighted.highlightType = .win
        highlighted.dateCreated = today
        let plain = QuickNote(title: "plain")
        plain.dateCreated = today
        [tagged, highlighted, plain].forEach(context.insert)

        let counts = DashboardStats.winCountsByDay(notes: [tagged, highlighted, plain], lastDays: 1, asOf: today, calendar: calendar)
        XCTAssertEqual(counts.first?.count, 2)
    }

    func testMoodTrendSkipsDaysWithoutAValue() throws {
        let context = try makeTestContext()
        let today = TestCalendar.date(2026, 6, 10)
        let withValue = DailyLog(date: calendar.startOfDay(for: TestCalendar.date(2026, 6, 10)))
        withValue.confidenceValue = 4
        let withoutValue = DailyLog(date: calendar.startOfDay(for: TestCalendar.date(2026, 6, 9)))
        [withValue, withoutValue].forEach(context.insert)

        let trend = DashboardStats.moodTrend(logs: [withValue, withoutValue], keyPath: \.confidenceValue, lastDays: 3, asOf: today, calendar: calendar)
        XCTAssertEqual(trend.count, 1)
        XCTAssertEqual(trend.first?.value, 4)
    }
}
