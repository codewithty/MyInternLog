import Foundation

struct WeeklyRecapStats {
    let entryCount: Int
    let topSkills: [String]
    let commonTheme: String?
    let biggestWin: QuickNote?
    let blockers: [QuickNote]
    let studyItemsAdded: [StudyItem]
    let photos: [AttachmentItem]
}

// Builds the "wrapped" stats for a week from raw notes/study items/attachments.
// Kept as a pure function (no SwiftData context) so it's easy to reason about
// and, eventually, unit test.
enum WeeklyRecapBuilder {
    static func build(
        notes: [QuickNote],
        studyItems: [StudyItem],
        attachments: [AttachmentItem],
        weekInterval: DateInterval
    ) -> WeeklyRecapStats {
        let weekNotes = notes.filter { weekInterval.contains($0.dateCreated) }

        let skillCounts = Dictionary(grouping: weekNotes.flatMap(\.knowledgeItems)) { $0.name }
            .mapValues(\.count)
        let topSkills = skillCounts.sorted { $0.value > $1.value }.prefix(3).map(\.key)

        let tagCounts = Dictionary(grouping: weekNotes.flatMap(\.tags)) { $0.name }
            .mapValues(\.count)
        let commonTheme = tagCounts.max { $0.value < $1.value }?.key

        let biggestWin = weekNotes
            .filter { $0.tag == .win || $0.highlightType == .win }
            .sorted { $0.dateCreated > $1.dateCreated }
            .first

        let blockers = weekNotes.filter { $0.tag == .blocker }

        let studyItemsAdded = studyItems.filter { weekInterval.contains($0.dateAdded) }

        let photos = attachments.filter {
            weekInterval.contains($0.createdAt) && $0.fileType.hasPrefix("image")
        }

        return WeeklyRecapStats(
            entryCount: weekNotes.count,
            topSkills: Array(topSkills),
            commonTheme: commonTheme,
            biggestWin: biggestWin,
            blockers: blockers,
            studyItemsAdded: studyItemsAdded,
            photos: photos
        )
    }
}
