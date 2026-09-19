import Foundation
import SwiftData

// Builds the "Export All Data" file. Read-only: it fetches records and copies them
// into DataExport, and never changes the database.
enum DataExporter {
    static let formatVersion = 1

    static func snapshot(from context: ModelContext, now: Date = .now) throws -> DataExport {
        func fetch<T: PersistentModel>(_ sortBy: SortDescriptor<T>...) throws -> [T] {
            try context.fetch(FetchDescriptor<T>(sortBy: sortBy))
        }

        let profile: [InternshipProfile] = try fetch()
        let notes: [QuickNote] = try fetch(SortDescriptor(\.dateCreated))
        let studyItems: [StudyItem] = try fetch(SortDescriptor(\.dateAdded))
        let dailyLogs: [DailyLog] = try fetch(SortDescriptor(\.date))
        let reflections: [Reflection] = try fetch(SortDescriptor(\.date))
        let attachments: [AttachmentItem] = try fetch(SortDescriptor(\.createdAt))
        let milestones: [Milestone] = try fetch(SortDescriptor(\.date))
        let reminders: [ReminderSetting] = try fetch(SortDescriptor(\.label))
        let careerOutputs: [CareerOutput] = try fetch(SortDescriptor(\.createdAt))
        let weeklyRecaps: [WeeklyRecap] = try fetch(SortDescriptor(\.weekStartDate))
        let tags: [Tag] = try fetch(SortDescriptor(\.name))
        let skills: [KnowledgeItem] = try fetch(SortDescriptor(\.name))
        let groups: [ProjectGroup] = try fetch(SortDescriptor(\.createdAt))

        return DataExport(
            app: "MyInternLog",
            formatVersion: formatVersion,
            exportedAt: now,
            profile: profile.first.map(record),
            notes: notes.map(record),
            studyItems: studyItems.map(record),
            dailyLogs: dailyLogs.map(record),
            reflections: reflections.map(record),
            attachments: attachments.map(record),
            milestones: milestones.map(record),
            reminders: reminders.map(record),
            careerOutputs: careerOutputs.map(record),
            weeklyRecaps: weeklyRecaps.map(record),
            tags: tags.map(\.name),
            skillsAndTools: skills.map(record),
            projectGroups: groups.map(record)
        )
    }

    static func jsonData(for export: DataExport) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(export)
    }

    // Writes the export to a temporary file, ready to hand to the share sheet.
    static func writeExportFile(from context: ModelContext, now: Date = .now) throws -> URL {
        let data = try jsonData(for: snapshot(from: context, now: now))
        let day = now.formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
        let url = URL.temporaryDirectory.appending(path: "MyInternLog-Export-\(day).json")
        try data.write(to: url, options: .atomic)
        return url
    }

    // MARK: Model -> record

    private static func record(_ profile: InternshipProfile) -> ProfileRecord {
        ProfileRecord(
            title: profile.title, organization: profile.organization, location: profile.location,
            startDate: profile.startDate, endDate: profile.endDate, presentationDate: profile.presentationDate,
            mentorName: profile.mentorName, mentorEmail: profile.mentorEmail, mentorPhone: profile.mentorPhone,
            schoolProgram: profile.schoolProgram, notes: profile.notes,
            useGenericWordingByDefault: profile.useGenericWordingByDefault, showWeekNumber: profile.showWeekNumber
        )
    }

    private static func record(_ note: QuickNote) -> NoteRecord {
        NoteRecord(
            id: note.id, title: note.title, body: note.body, dateCreated: note.dateCreated,
            tag: note.tagRawValue, highlight: note.highlightTypeRawValue,
            tags: note.tags.map(\.name).sorted(),
            skillsAndTools: note.knowledgeItems.map(\.name).sorted(),
            projectGroups: note.projectGroups.map(\.name).sorted(),
            dailyLogID: note.dailyLog?.id,
            attachmentIDs: note.attachments.map(\.id)
        )
    }

    private static func record(_ item: StudyItem) -> StudyItemRecord {
        StudyItemRecord(id: item.id, title: item.title, notes: item.notes, dateAdded: item.dateAdded, isReviewed: item.isReviewed)
    }

    private static func record(_ log: DailyLog) -> DailyLogRecord {
        DailyLogRecord(
            id: log.id, date: log.date, title: log.title, selfSummary: log.selfSummary, aiSummary: log.aiSummary,
            mood: log.moodValue, confidence: log.confidenceValue, energy: log.energyValue, stress: log.stressValue,
            isComplete: log.isComplete, createdAt: log.createdAt, updatedAt: log.updatedAt
        )
    }

    private static func record(_ reflection: Reflection) -> ReflectionRecord {
        ReflectionRecord(
            id: reflection.id, date: reflection.date, template: reflection.templateName,
            isComplete: reflection.isComplete, completedAt: reflection.completedAt,
            createdAt: reflection.createdAt, updatedAt: reflection.updatedAt,
            dailyLogID: reflection.dailyLog?.id,
            answers: reflection.answers
                .sorted { $0.displayOrder < $1.displayOrder }
                .map { AnswerRecord(prompt: $0.promptText, answer: $0.answerText, order: $0.displayOrder) }
        )
    }

    private static func record(_ attachment: AttachmentItem) -> AttachmentRecord {
        AttachmentRecord(
            id: attachment.id, fileName: attachment.fileName, fileType: attachment.fileType,
            caption: attachment.caption, notes: attachment.notes,
            createdAt: attachment.createdAt, updatedAt: attachment.updatedAt,
            noteID: attachment.quickNote?.id, dailyLogID: attachment.dailyLog?.id
        )
    }

    private static func record(_ milestone: Milestone) -> MilestoneRecord {
        MilestoneRecord(
            id: milestone.id, title: milestone.title, date: milestone.date, type: milestone.typeRawValue,
            notes: milestone.notes, reminder: milestone.reminderOptionRawValue,
            createdAt: milestone.createdAt, updatedAt: milestone.updatedAt
        )
    }

    private static func record(_ reminder: ReminderSetting) -> ReminderRecord {
        ReminderRecord(
            id: reminder.id, label: reminder.label, message: reminder.message, time: reminder.time,
            weekdays: reminder.enabledWeekdays, isEnabled: reminder.isEnabled, destination: reminder.destinationRawValue
        )
    }

    private static func record(_ output: CareerOutput) -> CareerOutputRecord {
        CareerOutputRecord(
            id: output.id, type: output.outputTypeRawValue, targetRole: output.targetRole,
            resumeStyle: output.resumeStyleRawValue, text: output.text, isFavorite: output.isFavorite,
            createdAt: output.createdAt, updatedAt: output.updatedAt
        )
    }

    private static func record(_ recap: WeeklyRecap) -> WeeklyRecapRecord {
        WeeklyRecapRecord(
            id: recap.id, weekStartDate: recap.weekStartDate, weekEndDate: recap.weekEndDate,
            title: recap.title, selfSummary: recap.selfSummary, aiSummary: recap.aiSummary,
            nextWeekFocus: recap.nextWeekFocus, isComplete: recap.isComplete,
            createdAt: recap.createdAt, updatedAt: recap.updatedAt
        )
    }

    private static func record(_ skill: KnowledgeItem) -> SkillRecord {
        SkillRecord(name: skill.name, category: skill.categoryRawValue)
    }

    private static func record(_ group: ProjectGroup) -> ProjectGroupRecord {
        ProjectGroupRecord(
            id: group.id, name: group.name, colorName: group.colorName, iconName: group.iconName,
            isArchived: group.isArchived, createdAt: group.createdAt, updatedAt: group.updatedAt
        )
    }
}
