import XCTest
import SwiftData
@testable import MyInternLog

@MainActor
final class XYZBulletBuilderTests: XCTestCase {

    // MARK: - Choosing notes

    func testSkipsQuestionsIdeasBlockersAndStudyNotes() throws {
        let context = try makeTestContext()
        let done = QuickNote(title: "Fixed the flaky test")
        let question = QuickNote(title: "Why does the cache miss?", tag: .question)
        let idea = QuickNote(title: "Batch the uploads", tag: .idea)
        let blocker = QuickNote(title: "Blocked on staging access", tag: .blocker)
        let study = QuickNote(title: "Read up on retries", tag: .studyLater)
        [done, question, idea, blocker, study].forEach(context.insert)

        let result = XYZBulletBuilder.notesForBullets(from: [done, question, idea, blocker, study])
        XCTAssertEqual(result.map(\.title), ["Fixed the flaky test"])
    }

    func testRemovesDuplicateTitlesIgnoringCaseAndSpaces() throws {
        let context = try makeTestContext()
        let a = QuickNote(title: "Set up the dev environment")
        let b = QuickNote(title: "  set up the DEV environment ")
        [a, b].forEach(context.insert)

        let result = XYZBulletBuilder.notesForBullets(from: [a, b])
        XCTAssertEqual(result.count, 1)
    }

    func testResumeWorthyAndWinsComeFirst() throws {
        let context = try makeTestContext()
        let plain = QuickNote(title: "Attended standup")
        let win = QuickNote(title: "Demoed the prototype", tag: .win)
        let resumeWorthy = QuickNote(title: "Shipped the export feature")
        resumeWorthy.highlightType = .resumeWorthy
        [plain, win, resumeWorthy].forEach(context.insert)

        let result = XYZBulletBuilder.notesForBullets(from: [plain, win, resumeWorthy])
        XCTAssertEqual(result.map(\.title), ["Shipped the export feature", "Demoed the prototype", "Attended standup"])
    }

    func testCapsNoteCountToFitContextWindow() throws {
        let context = try makeTestContext()
        let notes = (1...30).map { QuickNote(title: "Task \($0)") }
        notes.forEach(context.insert)

        XCTAssertEqual(XYZBulletBuilder.notesForBullets(from: notes).count, XYZBulletBuilder.maxNotes)
    }

    // MARK: - Prompt

    func testPromptTrimsLongBodiesAndIncludesRole() throws {
        let context = try makeTestContext()
        let note = QuickNote(title: "Wrote the parser", body: String(repeating: "a", count: 500))
        context.insert(note)

        let prompt = XYZBulletBuilder.prompt(notes: [note], targetRole: "iOS Engineer")
        XCTAssertTrue(prompt.contains("Target role: iOS Engineer"))
        XCTAssertFalse(prompt.contains(String(repeating: "a", count: XYZBulletBuilder.maxBodyLength + 1)))
    }

    // MARK: - Sentence assembly

    func testSentenceWithAllThreeParts() {
        let s = XYZBulletBuilder.sentence(
            accomplishment: "Stabilized a flaky test",
            measure: "passing 20 consecutive runs",
            method: "by adding a wait to the test setup"
        )
        XCTAssertEqual(s, "Stabilized a flaky test, passing 20 consecutive runs, by adding a wait to the test setup.")
    }

    func testSentenceDropsEmptyMeasureInsteadOfInventingOne() {
        let s = XYZBulletBuilder.sentence(accomplishment: "Set up the dev environment", measure: "  ", method: "by installing the toolchain")
        XCTAssertEqual(s, "Set up the dev environment, by installing the toolchain.")
    }

    func testSentenceAddsByWhenModelLeavesItOff() {
        let s = XYZBulletBuilder.sentence(accomplishment: "Cut upload time", measure: "", method: "Batching the requests.")
        XCTAssertEqual(s, "Cut upload time, by batching the requests.")
    }

    func testSentenceKeepsAcronymsCapitalized() {
        let s = XYZBulletBuilder.sentence(accomplishment: "Built a dashboard", measure: "", method: "API polling")
        XCTAssertEqual(s, "Built a dashboard, by API polling.")
    }
}
