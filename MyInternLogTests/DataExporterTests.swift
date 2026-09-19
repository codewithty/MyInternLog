import XCTest
import SwiftData
@testable import MyInternLog

@MainActor
final class DataExporterTests: XCTestCase {
    private let now = TestCalendar.date(2026, 9, 19)

    private func decode(_ data: Data) throws -> DataExport {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DataExport.self, from: data)
    }

    func testEmptyStoreExportsEmptyCollections() throws {
        let context = try makeTestContext()
        let export = try DataExporter.snapshot(from: context, now: now)

        XCTAssertEqual(export.app, "MyInternLog")
        XCTAssertEqual(export.formatVersion, 1)
        XCTAssertNil(export.profile)
        XCTAssertTrue(export.notes.isEmpty)
        XCTAssertTrue(export.dailyLogs.isEmpty)
        XCTAssertTrue(export.attachments.isEmpty)
    }

    func testNotesCarryTheirRelationships() throws {
        let context = try makeTestContext()
        let log = DailyLog(date: TestCalendar.date(2026, 6, 23))
        let tag = Tag(name: "meeting")
        let skill = KnowledgeItem(name: "Swift", category: .tool)
        let group = ProjectGroup(name: "Pipeline")
        context.insert(log)
        context.insert(tag)
        context.insert(skill)
        context.insert(group)

        let note = QuickNote(title: "Standup", body: "Went well", tag: .win)
        note.highlightType = .resumeWorthy
        context.insert(note)
        note.dailyLog = log
        note.tags = [tag]
        note.knowledgeItems = [skill]
        note.projectGroups = [group]

        let export = try DataExporter.snapshot(from: context, now: now)
        let record = try XCTUnwrap(export.notes.first)
        XCTAssertEqual(record.tag, "win")
        XCTAssertEqual(record.highlight, "resumeWorthy")
        XCTAssertEqual(record.tags, ["meeting"])
        XCTAssertEqual(record.skillsAndTools, ["Swift"])
        XCTAssertEqual(record.projectGroups, ["Pipeline"])
        XCTAssertEqual(record.dailyLogID, log.id)
        XCTAssertEqual(export.tags, ["meeting"])
        XCTAssertEqual(export.projectGroups.map(\.name), ["Pipeline"])
    }

    func testAttachmentsExportMetadataButNotDevicePaths() throws {
        let context = try makeTestContext()
        let note = QuickNote(title: "With a photo")
        context.insert(note)
        let attachment = AttachmentItem(fileName: "whiteboard.jpg", fileType: "image", localPath: "Attachments/private-device-path.jpg")
        attachment.caption = "Whiteboard"
        context.insert(attachment)
        note.attachments.append(attachment)

        let export = try DataExporter.snapshot(from: context, now: now)
        XCTAssertEqual(export.notes.first?.attachmentIDs, [attachment.id])
        XCTAssertEqual(export.attachments.first?.fileName, "whiteboard.jpg")
        XCTAssertEqual(export.attachments.first?.caption, "Whiteboard")

        let json = String(decoding: try DataExporter.jsonData(for: export), as: UTF8.self)
        XCTAssertFalse(json.contains("private-device-path"))
        XCTAssertFalse(json.contains("localPath"))
    }

    func testReflectionAnswersExportInDisplayOrder() throws {
        let context = try makeTestContext()
        let reflection = Reflection(date: now, templateName: "Quick")
        context.insert(reflection)
        let second = ReflectionAnswer(promptText: "B", answerText: "two", displayOrder: 1, templateName: "Quick")
        let first = ReflectionAnswer(promptText: "A", answerText: "one", displayOrder: 0, templateName: "Quick")
        context.insert(second)
        context.insert(first)
        reflection.answers = [second, first]

        let export = try DataExporter.snapshot(from: context, now: now)
        XCTAssertEqual(export.reflections.first?.answers.map(\.prompt), ["A", "B"])
    }

    func testJSONRoundTripsWithISO8601Dates() throws {
        let context = try makeTestContext()
        context.insert(StudyItem(title: "Review FFTs"))

        let data = try DataExporter.jsonData(for: DataExporter.snapshot(from: context, now: now))
        let decoded = try decode(data)

        XCTAssertEqual(decoded.studyItems.map(\.title), ["Review FFTs"])
        XCTAssertEqual(decoded.exportedAt.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 1)
        XCTAssertTrue(String(decoding: data, as: UTF8.self).contains("2026-09-19T"))
    }

    func testWriteExportFileUsesADatedNameAndValidJSON() throws {
        let context = try makeTestContext()
        context.insert(Tag(name: "meeting"))

        let url = try DataExporter.writeExportFile(from: context, now: now)
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertNotNil(url.lastPathComponent.range(of: #"^MyInternLog-Export-\d{4}-\d{2}-\d{2}\.json$"#, options: .regularExpression))
        let decoded = try decode(Data(contentsOf: url))
        XCTAssertEqual(decoded.tags, ["meeting"])
    }
}
