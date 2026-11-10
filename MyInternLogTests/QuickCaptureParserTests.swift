import XCTest
@testable import MyInternLog

final class QuickCaptureParserTests: XCTestCase {

    func testFirstLineIsTitleAndRestIsBody() {
        let result = QuickCaptureParser.split("Fixed the flaky test\nAdded a wait to setup.\nPassed 20 runs.")
        XCTAssertEqual(result.title, "Fixed the flaky test")
        XCTAssertEqual(result.body, "Added a wait to setup.\nPassed 20 runs.")
    }

    func testSingleShortLineHasEmptyBody() {
        let result = QuickCaptureParser.split("Demoed the prototype")
        XCTAssertEqual(result.title, "Demoed the prototype")
        XCTAssertEqual(result.body, "")
    }

    func testTrimsBlankLinesAndSpaces() {
        let result = QuickCaptureParser.split("\n\n   Set up the dev environment  \n\n  Installed the toolchain \n")
        XCTAssertEqual(result.title, "Set up the dev environment")
        XCTAssertEqual(result.body, "Installed the toolchain")
    }

    func testEmptyTextGivesEmptyParts() {
        let result = QuickCaptureParser.split("   \n  ")
        XCTAssertEqual(result.title, "")
        XCTAssertEqual(result.body, "")
    }

    func testLongSingleLineIsCutAtAWordAndKeptInBody() {
        let long = "Walked the whole team through the new ingest pipeline and collected feedback on error handling and retries"
        let result = QuickCaptureParser.split(long)
        XCTAssertLessThanOrEqual(result.title.count, QuickCaptureParser.maxTitleLength + 1)
        XCTAssertTrue(result.title.hasSuffix("…"))
        XCTAssertFalse(result.title.dropLast().hasSuffix(" "))
        XCTAssertEqual(result.body, long)
    }
}
