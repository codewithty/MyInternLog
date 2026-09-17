import SwiftUI
import SwiftData

struct ReflectionDetailView: View {
    @Bindable var reflection: Reflection
    @Environment(\.modelContext) private var context

    @State private var showingTemplateSwitchWarning = false
    @State private var pendingTemplate: ReflectionTemplate?

    private var sortedAnswers: [ReflectionAnswer] {
        reflection.answers.sorted { $0.displayOrder < $1.displayOrder }
    }

    private var hasAtLeastOneAnswer: Bool {
        reflection.answers.contains {
            !$0.answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private var todaysNotes: [QuickNote] {
        reflection.dailyLog?.quickNotes ?? []
    }

    var body: some View {
        List {
            if !todaysNotes.isEmpty {
                Section("Today's Notes (for context)") {
                    ForEach(todaysNotes) { note in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(note.title).font(.subheadline.bold())
                            if !note.body.isEmpty {
                                Text(note.body).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                            }
                        }
                    }
                }
            }

            Section {
                ForEach(sortedAnswers) { answer in
                    AnswerRow(answer: answer)
                }
                .onDelete(perform: deleteAnswers)

                Button {
                    addPrompt()
                } label: {
                    Label("Add Prompt", systemImage: "plus.circle")
                }
            } header: {
                Text("Prompts")
            } footer: {
                Text("Swipe to remove a prompt, or tap its title to edit the wording.")
            }

            if let dailyLog = reflection.dailyLog {
                MoodEnergySection(dailyLog: dailyLog)
            }

            Section {
                Menu {
                    ForEach(ReflectionTemplate.allCases, id: \.self) { template in
                        Button(template.rawValue) { requestTemplateSwitch(to: template) }
                    }
                } label: {
                    Label("Switch Template", systemImage: "arrow.triangle.2.circlepath")
                }
            }

            Section {
                if reflection.isComplete {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Completed")
                            .foregroundStyle(.green)
                        if let completedAt = reflection.completedAt {
                            Spacer()
                            Text(completedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Button("Mark Complete") {
                        reflection.isComplete = true
                        reflection.completedAt = Date()
                        reflection.updatedAt = Date()
                    }
                    .disabled(!hasAtLeastOneAnswer)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(reflection.date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
        .alert("Switch Template?", isPresented: $showingTemplateSwitchWarning, presenting: pendingTemplate) { template in
            Button("Switch", role: .destructive) { switchTemplate(to: template) }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("Some of your answered prompts aren't in the new template and will be removed. This can't be undone.")
        }
    }

    private func addPrompt() {
        let nextOrder = (reflection.answers.map(\.displayOrder).max() ?? -1) + 1
        let answer = ReflectionAnswer(promptText: "New prompt", displayOrder: nextOrder, templateName: reflection.templateName)
        context.insert(answer)
        reflection.answers.append(answer)
    }

    private func deleteAnswers(at offsets: IndexSet) {
        let toDelete = offsets.map { sortedAnswers[$0] }
        for answer in toDelete {
            reflection.answers.removeAll { $0.id == answer.id }
            context.delete(answer)
        }
    }

    private func requestTemplateSwitch(to template: ReflectionTemplate) {
        let newPrompts = Set(template.prompts)
        let wouldLoseAnswers = reflection.answers.contains {
            !$0.answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !newPrompts.contains($0.promptText)
        }
        if wouldLoseAnswers {
            pendingTemplate = template
            showingTemplateSwitchWarning = true
        } else {
            switchTemplate(to: template)
        }
    }

    private func switchTemplate(to template: ReflectionTemplate) {
        for answer in reflection.answers {
            context.delete(answer)
        }
        reflection.answers.removeAll()
        for (index, prompt) in template.prompts.enumerated() {
            let answer = ReflectionAnswer(promptText: prompt, displayOrder: index, templateName: template.rawValue)
            context.insert(answer)
            reflection.answers.append(answer)
        }
        reflection.templateName = template.rawValue
        reflection.updatedAt = Date()
    }
}

private struct MoodEnergySection: View {
    @Bindable var dailyLog: DailyLog

    var body: some View {
        Section("Mood & Energy (optional)") {
            MoodSlider(label: "Mood", low: "Rough", high: "Great", value: Binding(
                get: { dailyLog.moodValue ?? 3 },
                set: { dailyLog.moodValue = $0 }
            ))
            MoodSlider(label: "Confidence", low: "Unsure", high: "Confident", value: Binding(
                get: { dailyLog.confidenceValue ?? 3 },
                set: { dailyLog.confidenceValue = $0 }
            ))
            MoodSlider(label: "Energy", low: "Drained", high: "Energized", value: Binding(
                get: { dailyLog.energyValue ?? 3 },
                set: { dailyLog.energyValue = $0 }
            ))
            MoodSlider(label: "Stress", low: "Calm", high: "Stressed", value: Binding(
                get: { dailyLog.stressValue ?? 3 },
                set: { dailyLog.stressValue = $0 }
            ))
            TextField("Self summary (optional)", text: $dailyLog.selfSummary, axis: .vertical)
                .lineLimit(3...)
        }
    }
}

private struct MoodSlider: View {
    let label: String
    let low: String
    let high: String
    @Binding var value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label).font(.subheadline)
                Spacer()
                Text(MoodScale.label(value, low: low, high: high))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Int($0.rounded()) }
            ), in: 1...5, step: 1)
        }
    }
}

struct AnswerRow: View {
    @Bindable var answer: ReflectionAnswer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Prompt", text: $answer.promptText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("Your answer", text: $answer.answerText, axis: .vertical)
                .lineLimit(3...)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        Text("Tap a reflection in the list to open it.")
    }
}
