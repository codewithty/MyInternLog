import Foundation
import SwiftData

@Model
final class AttachmentItem {
    var id: UUID
    var fileName: String
    var fileType: String
    var localPath: String
    var caption: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    var quickNote: QuickNote?

    init(fileName: String, fileType: String, localPath: String) {
        self.id = UUID()
        self.fileName = fileName
        self.fileType = fileType
        self.localPath = localPath
        self.caption = ""
        self.notes = ""
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
