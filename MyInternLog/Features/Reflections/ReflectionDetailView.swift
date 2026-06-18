import SwiftUI
import SwiftData

struct ReflectionDetailView: View {
    @Bindable var reflection: Reflection

    private var sortedAnswers: [ReflectionAnswer] {
        reflection.answers.sorted { $0.displayOrder < $1.displayOrder }
    }

    private var hasAtLeastOneAnswer: Bool {
        reflection.answers.contains {
            !$0.answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var body: some View {
        List {
            ForEach(sortedAnswers) { answer in
                AnswerRow(answer: answer)
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
    }
}

struct AnswerRow: View {
    @Bindable var answer: ReflectionAnswer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(answer.promptText)
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
