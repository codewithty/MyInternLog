import Foundation
import SwiftData

// Builds a populated in-memory container for SwiftUI previews and learning —
// never used for the real app, and never containing real sensitive details.
enum SampleData {
    @MainActor
    static var container: ModelContainer = {
        let schema = Schema([
            QuickNote.self, StudyItem.self, Reflection.self, ReflectionAnswer.self,
            AttachmentItem.self, DailyLog.self, InternshipProfile.self, Milestone.self,
            ReminderSetting.self, CareerOutput.self, Tag.self, KnowledgeItem.self,
            ProjectGroup.self, WeeklyRecap.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        let profile = InternshipProfile()
        profile.title = "Software Engineering Intern"
        profile.organization = "Example Research Lab"
        profile.location = "Rome, NY"
        profile.startDate = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        profile.mentorName = "Jordan Lee"
        profile.schoolProgram = "State University"
        context.insert(profile)

        let group = ProjectGroup(name: "Radar Signal Project", colorName: "blue", iconName: "antenna.radiowaves.left.and.right")
        context.insert(group)

        let swift = KnowledgeItem(name: "Swift", category: .tool)
        let debugging = KnowledgeItem(name: "debugging", category: .skill)
        let radar = KnowledgeItem(name: "radar systems", category: .concept)
        [swift, debugging, radar].forEach(context.insert)

        let meetingTag = Tag(name: "meeting")
        let learningTag = Tag(name: "learning")
        [meetingTag, learningTag].forEach(context.insert)

        for offset in 0..<5 {
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let log = DailyLog(date: Calendar.current.startOfDay(for: date))
            log.moodValue = Int.random(in: 3...5)
            log.confidenceValue = Int.random(in: 2...5)
            context.insert(log)

            let note = QuickNote(title: "Sample note \(offset + 1)", body: "Worked on the signal processing pipeline.", tag: offset == 0 ? .win : .general)
            note.dailyLog = log
            note.tags = [learningTag]
            note.knowledgeItems = [swift, radar]
            note.projectGroups = [group]
            context.insert(note)
            log.quickNotes.append(note)

            let reflection = Reflection(date: date, templateName: ReflectionTemplate.quick.rawValue)
            reflection.isComplete = offset != 0
            reflection.dailyLog = log
            context.insert(reflection)
            log.reflections.append(reflection)
        }

        let studyItem = StudyItem(title: "Review FFT basics", notes: "Come back to this after reading the paper.")
        context.insert(studyItem)

        let milestone = Milestone(title: "Final Presentation", date: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(), type: .presentation)
        context.insert(milestone)

        let resumeBullet = CareerOutput(outputType: .resumeBullet, targetRole: "Software Engineer", text: "Built a signal-processing prototype used by the research team.")
        context.insert(resumeBullet)

        return container
    }()
}
