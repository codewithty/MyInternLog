import Foundation
import SwiftData

@Model
final class Reflection {
    var id: UUID
    var date: Date
    var templateName: String
    var isComplete: Bool
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade) var answers: [ReflectionAnswer]

    init(date: Date, templateName: String) {
        self.id = UUID()
        self.date = date
        self.templateName = templateName
        self.isComplete = false
        self.completedAt = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.answers = []
    }
}
