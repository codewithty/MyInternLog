import XCTest
@testable import MyInternLog

@MainActor
final class DateHelpersTests: XCTestCase {
    private let calendar = TestCalendar.calendar

    func testMonthGridIsWholeWeeks() {
        let grid = DateHelpers.monthGrid(for: TestCalendar.date(2026, 9, 15), calendar: calendar)
        XCTAssertEqual(grid.count % 7, 0)
    }

    func testMonthGridContainsEveryDayOfTheMonthOnce() {
        let grid = DateHelpers.monthGrid(for: TestCalendar.date(2026, 9, 15), calendar: calendar)
        let days = grid.compactMap { $0 }.map { calendar.component(.day, from: $0) }
        XCTAssertEqual(days, Array(1...30)) // September has 30 days
    }

    func testMonthGridHandlesLeapYearFebruary() {
        let grid = DateHelpers.monthGrid(for: TestCalendar.date(2028, 2, 10), calendar: calendar)
        XCTAssertEqual(grid.compactMap { $0 }.count, 29)
    }

    func testMonthGridLeadingPaddingMatchesFirstWeekday() {
        // September 1, 2026 is a Tuesday; with Sunday as the first weekday
        // that means two leading blanks (Sun, Mon).
        let grid = DateHelpers.monthGrid(for: TestCalendar.date(2026, 9, 15), calendar: calendar)
        XCTAssertNil(grid[0])
        XCTAssertNil(grid[1])
        XCTAssertNotNil(grid[2])
        XCTAssertEqual(calendar.component(.day, from: grid[2]!), 1)
    }
}
