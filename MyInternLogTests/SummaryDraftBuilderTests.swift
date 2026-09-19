import XCTest
import SwiftData
@testable import MyInternLog

@MainActor
final class SummaryDraftBuilderTests: XCTestCase {
    func testWhatDidIDoListsEveryNoteTitle() throws {
        let context = try makeTestContext()
        let a = QuickNote(title: "Wrote the parser")
        let b = QuickNote(title: "Reviewed the paper")
        [a, b].forEach(context.insert)

        let result = SummaryDraftBuilder.suggestions(for: ["What did I do?"], notes: [a, b], openStudyItems: [])
        XCTAssertEqual(result["What did I do?"], "- Wrote the parser\n- Reviewed the paper")
    }

    func testProblemsPromptUsesOnlyBlockers() throws {
        let context = try makeTestContext()
        let blocker = QuickNote(title: "Build keeps failing", tag: .blocker)
        let normal = QuickNote(title: "Standup")
        [blocker, normal].forEach(context.insert)

        let result = SummaryDraftBuilder.suggestions(for: ["Problems faced"], notes: [blocker, normal], openStudyItems: [])
        XCTAssertEqual(result["Problems faced"], "- Build keeps failing")
    }

    func testStudyPromptIncludesOpenStudyItems() throws {
        let context = try makeTestContext()
        let studyLater = QuickNote(title: "Read about FFTs", tag: .studyLater)
        let item = StudyItem(title: "Review Kalman filters")
        [studyLater].forEach(context.insert)
        context.insert(item)

        let result = SummaryDraftBuilder.suggestions(for: ["Things to study later"], notes: [studyLater], openStudyItems: [item])
        XCTAssertEqual(result["Things to study later"], "- Read about FFTs\n- Review Kalman filters")
    }

    func testPromptsWithNothingToSuggestAreOmitted() throws {
        let result = SummaryDraftBuilder.suggestions(for: ["Wins / accomplishments", "Freeform notes"], notes: [], openStudyItems: [])
        XCTAssertTrue(result.isEmpty)
    }

    func testSkillsPromptListsUniqueKnowledgeItems() throws {
        let context = try makeTestContext()
        let swift = KnowledgeItem(name: "Swift", category: .tool)
        context.insert(swift)
        let a = QuickNote(title: "a")
        a.knowledgeItems = [swift]
        let b = QuickNote(title: "b")
        b.knowledgeItems = [swift]
        [a, b].forEach(context.insert)

        let result = SummaryDraftBuilder.suggestions(for: ["Skills, tools, and concepts used"], notes: [a, b], openStudyItems: [])
        XCTAssertEqual(result["Skills, tools, and concepts used"], "- Swift")
    }
}
