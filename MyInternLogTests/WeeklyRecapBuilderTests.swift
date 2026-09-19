import XCTest
import SwiftData
@testable import MyInternLog

@MainActor
final class WeeklyRecapBuilderTests: XCTestCase {
    private let week = DateInterval(
        start: TestCalendar.date(2026, 6, 7, hour: 0),
        end: TestCalendar.date(2026, 6, 14, hour: 0)
    )

    private func note(_ title: String, tag: NoteTag = .general, on day: Int, in context: ModelContext) -> QuickNote {
        let note = QuickNote(title: title, tag: tag)
        note.dateCreated = TestCalendar.date(2026, 6, day)
        context.insert(note)
        return note
    }

    func testOnlyNotesInsideTheWeekAreCounted() throws {
        let context = try makeTestContext()
        let inside = note("inside", on: 9, in: context)
        let outside = note("outside", on: 20, in: context)

        let stats = WeeklyRecapBuilder.build(notes: [inside, outside], studyItems: [], attachments: [], weekInterval: week)
        XCTAssertEqual(stats.entryCount, 1)
    }

    func testBiggestWinIsTheMostRecentWin() throws {
        let context = try makeTestContext()
        let early = note("early win", tag: .win, on: 8, in: context)
        let late = note("late win", tag: .win, on: 12, in: context)

        let stats = WeeklyRecapBuilder.build(notes: [early, late], studyItems: [], attachments: [], weekInterval: week)
        XCTAssertEqual(stats.biggestWin?.title, "late win")
    }

    func testBlockersAreCollected() throws {
        let context = try makeTestContext()
        let blocker = note("stuck", tag: .blocker, on: 9, in: context)
        let normal = note("fine", on: 9, in: context)

        let stats = WeeklyRecapBuilder.build(notes: [blocker, normal], studyItems: [], attachments: [], weekInterval: week)
        XCTAssertEqual(stats.blockers.map(\.title), ["stuck"])
    }

    func testTopSkillsAreRankedByFrequency() throws {
        let context = try makeTestContext()
        let swift = KnowledgeItem(name: "Swift", category: .tool)
        let python = KnowledgeItem(name: "Python", category: .tool)
        [swift, python].forEach(context.insert)

        let first = note("one", on: 8, in: context)
        first.knowledgeItems = [swift, python]
        let second = note("two", on: 9, in: context)
        second.knowledgeItems = [swift]

        let stats = WeeklyRecapBuilder.build(notes: [first, second], studyItems: [], attachments: [], weekInterval: week)
        XCTAssertEqual(stats.topSkills.first, "Swift")
    }

    func testCommonThemeIsTheMostUsedTag() throws {
        let context = try makeTestContext()
        let meeting = Tag(name: "meeting")
        let debugging = Tag(name: "debugging")
        [meeting, debugging].forEach(context.insert)

        let first = note("one", on: 8, in: context)
        first.tags = [debugging]
        let second = note("two", on: 9, in: context)
        second.tags = [debugging, meeting]

        let stats = WeeklyRecapBuilder.build(notes: [first, second], studyItems: [], attachments: [], weekInterval: week)
        XCTAssertEqual(stats.commonTheme, "debugging")
    }

    func testEmptyWeekProducesEmptyStats() {
        let stats = WeeklyRecapBuilder.build(notes: [], studyItems: [], attachments: [], weekInterval: week)
        XCTAssertEqual(stats.entryCount, 0)
        XCTAssertNil(stats.biggestWin)
        XCTAssertNil(stats.commonTheme)
        XCTAssertTrue(stats.topSkills.isEmpty)
    }
}
