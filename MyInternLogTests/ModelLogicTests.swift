import XCTest
@testable import MyInternLog

@MainActor
final class ModelLogicTests: XCTestCase {
    private let calendar = TestCalendar.calendar

    // MARK: InternshipProfile.weekNumber

    func testWeekNumberIsOneOnTheStartDate() {
        let profile = InternshipProfile()
        profile.startDate = TestCalendar.date(2026, 6, 22)
        XCTAssertEqual(profile.weekNumber(asOf: TestCalendar.date(2026, 6, 22)), 1)
    }

    func testWeekNumberAdvancesEverySevenDays() {
        let profile = InternshipProfile()
        profile.startDate = TestCalendar.date(2026, 6, 22)
        XCTAssertEqual(profile.weekNumber(asOf: TestCalendar.date(2026, 6, 28)), 1)
        XCTAssertEqual(profile.weekNumber(asOf: TestCalendar.date(2026, 6, 29)), 2)
        XCTAssertEqual(profile.weekNumber(asOf: TestCalendar.date(2026, 8, 3)), 7)
    }

    func testWeekNumberIsNilWithoutStartDateOrBeforeStart() {
        let profile = InternshipProfile()
        XCTAssertNil(profile.weekNumber(asOf: TestCalendar.date(2026, 6, 22)))

        profile.startDate = TestCalendar.date(2026, 6, 22)
        XCTAssertNil(profile.weekNumber(asOf: TestCalendar.date(2026, 6, 1)))
    }

    // MARK: MilestoneReminderOption

    func testMilestoneReminderFireDates() {
        let milestone = TestCalendar.date(2026, 7, 15)

        let exact = MilestoneReminderOption.exactDate.fireDate(for: milestone, calendar: calendar)!
        XCTAssertEqual(calendar.dateComponents([.month, .day, .hour], from: exact), DateComponents(month: 7, day: 15, hour: 9))

        let dayBefore = MilestoneReminderOption.dayBefore.fireDate(for: milestone, calendar: calendar)!
        XCTAssertEqual(calendar.component(.day, from: dayBefore), 14)

        let weekBefore = MilestoneReminderOption.weekBefore.fireDate(for: milestone, calendar: calendar)!
        XCTAssertEqual(calendar.component(.day, from: weekBefore), 8)

        XCTAssertNil(MilestoneReminderOption.none.fireDate(for: milestone, calendar: calendar))
    }

    func testMilestoneTypesIncludeCUNYPresentationSeparately() {
        XCTAssertTrue(MilestoneType.allCases.contains(.cunyPresentation))
        XCTAssertTrue(MilestoneType.allCases.contains(.presentation))
        XCTAssertNotEqual(MilestoneType.cunyPresentation.label, MilestoneType.presentation.label)
    }

    // MARK: Search filters

    func testConfidenceFilterBuckets() {
        XCTAssertTrue(ConfidenceFilter.any.matches(nil))
        XCTAssertTrue(ConfidenceFilter.low.matches(1))
        XCTAssertTrue(ConfidenceFilter.low.matches(2))
        XCTAssertFalse(ConfidenceFilter.low.matches(3))
        XCTAssertTrue(ConfidenceFilter.medium.matches(3))
        XCTAssertTrue(ConfidenceFilter.high.matches(4))
        XCTAssertTrue(ConfidenceFilter.high.matches(5))
        XCTAssertFalse(ConfidenceFilter.high.matches(nil))
    }

    func testSearchFiltersDefaultsAndTypeSelection() {
        var filters = SearchFilters()
        XCTAssertTrue(filters.isDefault)
        XCTAssertTrue(filters.includes(.notes)) // no types selected = search everything

        filters.activeTypes = [.milestones]
        XCTAssertFalse(filters.isDefault)
        XCTAssertTrue(filters.includes(.milestones))
        XCTAssertFalse(filters.includes(.notes))
    }

    // MARK: Reflection templates

    func testReflectionTemplatePromptCounts() {
        XCTAssertEqual(ReflectionTemplate.quick.prompts.count, 3)
        XCTAssertEqual(ReflectionTemplate.full.prompts.count, 10)
    }

    // MARK: AI prompt builder

    func testPromptUsesGenericWordingWhenRequested() throws {
        let profile = InternshipProfile()
        profile.title = "Research Intern"
        profile.organization = "Secret Lab"

        let generic = AIPromptBuilder.buildPrompt(
            type: .dailySummary, targetRole: "", notes: [], reflections: [], profile: profile, useGenericWording: true
        )
        XCTAssertFalse(generic.contains("Secret Lab"))

        let specific = AIPromptBuilder.buildPrompt(
            type: .dailySummary, targetRole: "", notes: [], reflections: [], profile: profile, useGenericWording: false
        )
        XCTAssertTrue(specific.contains("Secret Lab"))
    }

    func testPromptAlwaysIncludesSensitiveDetailsReminder() {
        let prompt = AIPromptBuilder.buildPrompt(
            type: .cunyPresentationPrep, targetRole: "", notes: [], reflections: [], profile: InternshipProfile(), useGenericWording: true
        )
        XCTAssertTrue(prompt.localizedCaseInsensitiveContains("sensitive"))
    }
}
