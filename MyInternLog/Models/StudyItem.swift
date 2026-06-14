import Foundation
import SwiftData

@Model
final class StudyItem {
    var id: UUID
    var title: String
    var notes: String
    var dateAdded: Date
    var isReviewed: Bool

    init(title: String, notes: String = "") {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.dateAdded = Date()
        self.isReviewed = false
    }
}
