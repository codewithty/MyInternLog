import Foundation
import SwiftData

enum KnowledgeCategory: String, CaseIterable {
    case skill
    case tool
    case concept

    var label: String {
        switch self {
        case .skill: return "Skill"
        case .tool: return "Tool"
        case .concept: return "Concept"
        }
    }
}

// A reusable skill/tool/concept (e.g. "debugging", "Swift", "radar systems").
@Model
final class KnowledgeItem {
    var id: UUID
    var name: String
    var categoryRawValue: String
    var createdAt: Date

    var category: KnowledgeCategory {
        get { KnowledgeCategory(rawValue: categoryRawValue) ?? .concept }
        set { categoryRawValue = newValue.rawValue }
    }

    init(name: String, category: KnowledgeCategory) {
        self.id = UUID()
        self.name = name
        self.categoryRawValue = category.rawValue
        self.createdAt = Date()
    }

    static func findOrCreate(named name: String, category: KnowledgeCategory, in context: ModelContext) -> KnowledgeItem {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<KnowledgeItem>(predicate: #Predicate { $0.name == trimmed })
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let item = KnowledgeItem(name: trimmed, category: category)
        context.insert(item)
        return item
    }
}
