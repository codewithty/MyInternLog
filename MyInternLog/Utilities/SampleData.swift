import Foundation
import SwiftData

// Builds a populated in-memory container for demo mode and SwiftUI previews.
// It is never the real store, and it contains no real or sensitive details.
enum SampleData {
    private static let noteIdeas: [(title: String, body: String, tag: NoteTag)] = [
        ("Set up the dev environment", "Installed the toolchain and got the repo building locally.", .general),
        ("Standup takeaways", "The team is prioritizing the ingest bug. I'll pair with Jordan tomorrow.", .general),
        ("Fixed the flaky test", "It was a race in the test setup. Added a wait and it passed 20 runs in a row.", .win),
        ("Why does the cache miss?", "Requests skip the cache when the header casing differs. Ask my mentor if that's intended.", .question),
        ("Idea: batch the uploads", "Batching would cut the number of round trips. Worth a quick prototype.", .idea),
        ("Blocked on staging access", "Still waiting on credentials, so I can't verify the fix end to end.", .blocker),
        ("Read up on retry strategies", "Exponential backoff with jitter. I need to understand when it hurts.", .studyLater),
        ("Demoed the prototype", "Walked the team through the pipeline and got good feedback on error handling.", .win)
    ]

    private static let reflectionReplies = [
        "Fixed a flaky test and paired on the ingest bug.",
        "How retries and backoff interact with rate limits.",
        "Circle back to the caching behavior once staging access lands."
    ]

    @MainActor
    static var container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container: ModelContainer
        do {
            container = try ModelContainer(for: AppSchema.schema, configurations: [config])
        } catch {
            fatalError("Could not build the sample data store: \(error)")
        }
        let context = container.mainContext
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        let profile = InternshipProfile()
        profile.title = "Software Engineering Intern"
        profile.organization = "Example Research Lab"
        profile.location = "Anytown, USA"
        profile.startDate = calendar.date(byAdding: .day, value: -21, to: today)
        profile.endDate = calendar.date(byAdding: .day, value: 35, to: today)
        profile.mentorName = "Jordan Lee"
        profile.schoolProgram = "State University"
        context.insert(profile)

        let group = ProjectGroup(name: "Data Pipeline Project", colorName: "blue", iconName: "chart.bar.doc.horizontal")
        context.insert(group)

        let swift = KnowledgeItem(name: "Swift", category: .tool)
        let debugging = KnowledgeItem(name: "debugging", category: .skill)
        let pipelines = KnowledgeItem(name: "data pipelines", category: .concept)
        [swift, debugging, pipelines].forEach(context.insert)

        let meetingTag = Tag(name: "meeting")
        let learningTag = Tag(name: "learning")
        [meetingTag, learningTag].forEach(context.insert)

        // Three weeks of weekdays, so the dashboard, calendar, and recaps have history to show.
        var noteIndex = 0
        for offset in 0..<21 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            // Weekends off, except the last two days, so the streak card never opens at 0
            // when a tester happens to try demo mode on a weekend.
            let weekday = calendar.component(.weekday, from: day)
            if (weekday == 1 || weekday == 7) && offset > 1 { continue }

            let log = DailyLog(date: day)
            log.moodValue = 3 + offset % 3
            log.confidenceValue = 2 + offset % 4
            log.energyValue = 2 + offset % 3
            log.stressValue = 1 + offset % 4
            log.isComplete = offset != 0
            context.insert(log)

            for slot in 0..<(1 + offset % 2) {
                let idea = noteIdeas[noteIndex % noteIdeas.count]
                noteIndex += 1
                let note = QuickNote(title: idea.title, body: idea.body, tag: idea.tag)
                note.dateCreated = calendar.date(byAdding: .hour, value: 9 + slot * 3, to: day) ?? day
                if idea.tag == .win { note.highlightType = .resumeWorthy }
                context.insert(note)
                note.dailyLog = log
                note.tags = idea.tag == .question || idea.tag == .studyLater ? [learningTag] : [meetingTag]
                note.knowledgeItems = noteIndex % 2 == 0 ? [swift, debugging] : [pipelines]
                note.projectGroups = [group]
            }

            // A completed reflection every day, because the streak counts completed reflections.
            let template = ReflectionTemplate.quick
            let reflection = Reflection(date: day, templateName: template.rawValue)
            reflection.isComplete = true
            reflection.completedAt = day
            context.insert(reflection)
            reflection.dailyLog = log
            for (order, prompt) in template.prompts.enumerated() {
                let answer = ReflectionAnswer(promptText: prompt, answerText: reflectionReplies[order % reflectionReplies.count], displayOrder: order, templateName: template.rawValue)
                context.insert(answer)
                reflection.answers.append(answer)
            }
        }

        let reviewed = StudyItem(title: "Review retry and backoff patterns", notes: "Start with the exponential backoff write-up.")
        reviewed.isReviewed = true
        context.insert(reviewed)
        context.insert(StudyItem(title: "Read about HTTP caching headers", notes: "Ties into the cache-miss question."))
        context.insert(StudyItem(title: "Learn how the ingest queue is partitioned"))

        context.insert(Milestone(title: "Mentor check-in", date: calendar.date(byAdding: .day, value: 3, to: today) ?? today, type: .mentorMeeting))
        context.insert(Milestone(title: "Final Presentation", date: calendar.date(byAdding: .day, value: 30, to: today) ?? today, type: .presentation))

        context.insert(CareerOutput(outputType: .resumeBullet, targetRole: "Software Engineer", resumeStyle: .technical, text: "Built a data-pipeline prototype and fixed a flaky test suite, cutting CI failures for the team."))
        context.insert(CareerOutput(outputType: .interviewTalkingPoint, targetRole: "Software Engineer", text: "Tell the story of tracking down the race condition in the test setup."))

        return container
    }()
}
