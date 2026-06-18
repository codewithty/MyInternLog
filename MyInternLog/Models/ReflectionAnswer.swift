import Foundation
import SwiftData

@Model
final class ReflectionAnswer {
    var id: UUID
    var promptText: String
    var answerText: String
    var displayOrder: Int
    var templateName: String
    var createdAt: Date
    var updatedAt: Date

    init(promptText: String, answerText: String = "", displayOrder: Int, templateName: String) {
        self.id = UUID()
        self.promptText = promptText
        self.answerText = answerText
        self.displayOrder = displayOrder
        self.templateName = templateName
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
