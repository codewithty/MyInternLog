import Foundation
import SwiftData

// SwiftData can't persist enums directly, so we store the raw String
// and convert via a computed property.
enum NoteTag: String, CaseIterable {
    case general
    case question
    case win
    case insight
}

@Model
final class QuickNote {
    var id: UUID
    var title: String
    var body: String
    var dateCreated: Date
    var tagRawValue: String

    var tag: NoteTag {
        get { NoteTag(rawValue: tagRawValue) ?? .general }
        set { tagRawValue = newValue.rawValue }
    }

    init(title: String, body: String = "", tag: NoteTag = .general) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.dateCreated = Date()
        self.tagRawValue = tag.rawValue
    }
}
