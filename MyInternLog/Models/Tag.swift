import Foundation
import SwiftData

// Freeform, reusable label. The same Tag instance is shared across every
// QuickNote it's attached to, so typing "meeting" once makes it reusable.
@Model
final class Tag {
    var id: UUID
    var name: String
    var createdAt: Date

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }

    static let starterSuggestions = ["meeting", "learning", "debugging", "win", "question", "study later", "blocker"]

    static func findOrCreate(named name: String, in context: ModelContext) -> Tag {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let descriptor = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == trimmed })
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let tag = Tag(name: trimmed)
        context.insert(tag)
        return tag
    }
}
