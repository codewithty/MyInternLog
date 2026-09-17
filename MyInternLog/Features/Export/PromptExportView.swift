import SwiftUI
import SwiftData

struct PromptExportView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \QuickNote.dateCreated, order: .reverse) private var allNotes: [QuickNote]
    @Query(sort: \Reflection.date, order: .reverse) private var allReflections: [Reflection]

    @State private var outputType: CareerOutputType
    @State private var targetRole = ""
    @State private var resumeStyle: ResumeBulletStyle = .beginner
    @State private var prompt = ""
    @State private var pastedResult = ""
    @State private var copied = false

    init(initialType: CareerOutputType = .dailySummary) {
        _outputType = State(initialValue: initialType)
    }

    private var profile: InternshipProfile {
        InternshipProfile.current(in: context)
    }

    private var sourceNotes: [QuickNote] {
        switch outputType {
        case .dailySummary:
            return allNotes.filter { Calendar.current.isDateInToday($0.dateCreated) }
        case .weeklyRecap:
            let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return allNotes.filter { $0.dateCreated >= cutoff }
        case .endOfInternshipSummary:
            return allNotes
        default:
            return Array(allNotes.prefix(20))
        }
    }

    private var sourceReflections: [Reflection] {
        switch outputType {
        case .dailySummary:
            return allReflections.filter { Calendar.current.isDateInToday($0.date) }
        case .weeklyRecap:
            let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return allReflections.filter { $0.date >= cutoff }
        case .endOfInternshipSummary:
            return allReflections
        default:
            return Array(allReflections.prefix(10))
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("What are you creating?") {
                    Picker("Type", selection: $outputType) {
                        ForEach(CareerOutputType.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .onChange(of: outputType) { _, _ in regeneratePrompt() }

                    if outputType == .resumeBullet || outputType == .interviewTalkingPoint {
                        TextField("Target role (optional)", text: $targetRole)
                            .onChange(of: targetRole) { _, _ in regeneratePrompt() }
                    }

                    if outputType == .resumeBullet {
                        Picker("Style", selection: $resumeStyle) {
                            ForEach(ResumeBulletStyle.allCases, id: \.self) { style in
                                Text(style.label).tag(style)
                            }
                        }
                        .onChange(of: resumeStyle) { _, _ in regeneratePrompt() }
                    }
                }

                Section {
                    Text("Review this prompt for sensitive, confidential, or classified details before copying it anywhere.")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                } header: {
                    Text("1. Copy This Prompt")
                }

                Section {
                    TextEditor(text: $prompt)
                        .frame(minHeight: 160)
                        .font(.callout)

                    Button {
                        UIPasteboard.general.string = prompt
                        copied = true
                    } label: {
                        Label(copied ? "Copied!" : "Copy Prompt", systemImage: "doc.on.doc")
                    }
                }

                Section {
                    Text("Paste it into ChatGPT (or similar), then bring the result back here.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("2. Paste The Result")
                }

                Section {
                    TextEditor(text: $pastedResult)
                        .frame(minHeight: 160)
                        .font(.callout)
                }
            }
            .navigationTitle("AI Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveResult() }
                        .disabled(pastedResult.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear { regeneratePrompt() }
        }
    }

    private func regeneratePrompt() {
        copied = false
        prompt = AIPromptBuilder.buildPrompt(
            type: outputType,
            targetRole: targetRole,
            resumeStyle: outputType == .resumeBullet ? resumeStyle : nil,
            notes: sourceNotes,
            reflections: sourceReflections,
            profile: profile,
            useGenericWording: profile.useGenericWordingByDefault
        )
    }

    private func saveResult() {
        let output = CareerOutput(
            outputType: outputType,
            targetRole: targetRole,
            resumeStyle: outputType == .resumeBullet ? resumeStyle : nil,
            text: pastedResult
        )
        context.insert(output)
        dismiss()
    }
}

#Preview {
    PromptExportView()
        .modelContainer(for: [QuickNote.self, Reflection.self, InternshipProfile.self, CareerOutput.self], inMemory: true)
}
