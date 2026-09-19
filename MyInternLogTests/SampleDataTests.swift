import XCTest
import SwiftData
@testable import MyInternLog

// Demo mode is only useful if the sample store actually fills the screens testers look at.
@MainActor
final class SampleDataTests: XCTestCase {
    func testDemoDataSpansThreeWeeksWithVariedNotes() throws {
        let context = SampleData.container.mainContext
        let notes = try context.fetch(FetchDescriptor<QuickNote>())

        let days = Set(notes.map { Calendar.current.startOfDay(for: $0.dateCreated) })
        XCTAssertGreaterThanOrEqual(days.count, 14)
        XCTAssertTrue(notes.contains { $0.tag == .win })
        XCTAssertTrue(notes.contains { $0.tag == .blocker })
        XCTAssertTrue(notes.contains { $0.tag == .studyLater })
    }

    func testDemoDataIncludesReflectionsStudyItemsAndMilestones() throws {
        let context = SampleData.container.mainContext

        let reflections = try context.fetch(FetchDescriptor<Reflection>())
        XCTAssertTrue(reflections.contains { $0.isComplete && !$0.answers.isEmpty })
        XCTAssertFalse(try context.fetch(FetchDescriptor<StudyItem>()).isEmpty)
        XCTAssertGreaterThanOrEqual(try context.fetch(FetchDescriptor<Milestone>()).count, 2)
    }

    func testDemoDataAlwaysShowsARunningStreak() throws {
        let context = SampleData.container.mainContext
        let reflections = try context.fetch(FetchDescriptor<Reflection>())
        XCTAssertGreaterThanOrEqual(DashboardStats.currentStreak(reflections: reflections), 2)
    }

    func testDemoDataNeverMentionsARealEmployer() throws {
        let context = SampleData.container.mainContext
        let profile = try XCTUnwrap(context.fetch(FetchDescriptor<InternshipProfile>()).first)
        XCTAssertEqual(profile.organization, "Example Research Lab")
    }
}
