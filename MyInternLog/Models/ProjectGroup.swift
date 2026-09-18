import Foundation
import SwiftData

@Model
final class ProjectGroup {
    var id: UUID
    var name: String
    var colorName: String
    var iconName: String
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date

    init(name: String, colorName: String = "blue", iconName: String = "folder.fill") {
        self.id = UUID()
        self.name = name
        self.colorName = colorName
        self.iconName = iconName
        self.isArchived = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Every install gets a default "Internship" group so notes have
    // somewhere to land before the user creates their own groups.
    static func ensureDefault(in context: ModelContext) {
        let descriptor = FetchDescriptor<ProjectGroup>()
        guard let existing = try? context.fetch(descriptor), existing.isEmpty else { return }
        context.insert(ProjectGroup(name: "Internship", colorName: "blue", iconName: "briefcase.fill"))
    }
}
