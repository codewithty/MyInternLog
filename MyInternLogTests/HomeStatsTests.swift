import XCTest
import SwiftData
@testable import MyInternLog

@MainActor
final class HomeStatsTests: XCTestCase {

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        cal.firstWeekday = 1
        return cal
    }

    private func date(_ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour))!
    }

    private func note(on day: Int, tag: NoteTag = .general) -> QuickNote {
        let note = QuickNote(title: "Note \(day)", tag: tag)
        note.dateCreated = date(day)
        return note
    }

    func testNotesThisWeekOnlyCountsCurrentWeek() throws {
        let context = try makeTestContext()
        // Nov 8, 2026 is a Sunday, so the week of Nov 9 runs Nov 8 to Nov 14.
        let notes = [note(on: 7), note(on: 8), note(on: 9), note(on: 10)]
        notes.forEach(context.insert)
        XCTAssertEqual(HomeStats.notesThisWeek(notes, asOf: date(10), calendar: calendar).count, 3)
    }

    func testWinsCountTagOrHighlight() throws {
        let context = try makeTestContext()
        let tagged = note(on: 9, tag: .win)
        let highlighted = note(on: 9)
        highlighted.highlightType = .win
        let plain = note(on: 9)
        [tagged, highlighted, plain].forEach(context.insert)
        XCTAssertEqual([tagged, highlighted, plain].filter(HomeStats.isWin).count, 2)
    }

    func testStreakCountsBackFromToday() throws {
        let context = try makeTestContext()
        let notes = [note(on: 7), note(on: 8), note(on: 9)]
        notes.forEach(context.insert)
        XCTAssertEqual(HomeStats.captureStreak(notes, asOf: date(9), calendar: calendar), 3)
    }

    func testStreakKeepsYesterdayWhenNothingLoggedYetToday() throws {
        let context = try makeTestContext()
        let notes = [note(on: 7), note(on: 8)]
        notes.forEach(context.insert)
        XCTAssertEqual(HomeStats.captureStreak(notes, asOf: date(9), calendar: calendar), 2)
    }

    func testStreakBreaksOnAMissedDay() throws {
        let context = try makeTestContext()
        let notes = [note(on: 5), note(on: 7), note(on: 8)]
        notes.forEach(context.insert)
        XCTAssertEqual(HomeStats.captureStreak(notes, asOf: date(8), calendar: calendar), 2)
        XCTAssertEqual(HomeStats.captureStreak(notes, asOf: date(11), calendar: calendar), 0)
    }
}
