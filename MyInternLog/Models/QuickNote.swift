import Foundation
import SwiftData

// SwiftData can't persist enums directly, so we store the raw String
// and convert via a computed property.
enum NoteTag: String, CaseIterable {
    case general
    case idea
    case question
    case win
    case blocker
    case studyLater

    var label: String {
        switch self {
        case .general: return "Note"
        case .idea: return "Idea"
        case .question: return "Question"
        case .win: return "Win"
        case .blocker: return "Blocker"
        case .studyLater: return "Study Later"
        }
    }
}

// Marks a note as material worth pulling into summaries, PDFs, or resume prep.
enum HighlightType: String, CaseIterable {
    case win
    case important
    case resumeWorthy
    case studyLater

    var label: String {
        switch self {
        case .win: return "Win"
        case .important: return "Important"
        case .resumeWorthy: return "Resume-Worthy"
        case .studyLater: return "Study Later"
        }
    }
}

@Model
final class QuickNote {
    var id: UUID
    var title: String
    var body: String
    var dateCreated: Date
    var tagRawValue: String
    var highlightTypeRawValue: String?
    @Relationship(deleteRule: .cascade) var attachments: [AttachmentItem]
    @Relationship var tags: [Tag]
    @Relationship var knowledgeItems: [KnowledgeItem]
    @Relationship var projectGroups: [ProjectGroup]
    var dailyLog: DailyLog?

    var tag: NoteTag {
        get { NoteTag(rawValue: tagRawValue) ?? .general }
        set { tagRawValue = newValue.rawValue }
    }

    var highlightType: HighlightType? {
        get { highlightTypeRawValue.flatMap { HighlightType(rawValue: $0) } }
        set { highlightTypeRawValue = newValue?.rawValue }
    }

    init(title: String, body: String = "", tag: NoteTag = .general) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.dateCreated = Date()
        self.tagRawValue = tag.rawValue
        self.highlightTypeRawValue = nil
        self.attachments = []
        self.tags = []
        self.knowledgeItems = []
        self.projectGroups = []
    }
}
