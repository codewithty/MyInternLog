import SwiftUI
import SwiftData

struct StartReflectionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTemplate: ReflectionTemplate = .quick

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Template", selection: $selectedTemplate) {
                        ForEach(ReflectionTemplate.allCases, id: \.self) { template in
                            Text(template.rawValue).tag(template)
                        }
                    }
                } footer: {
                    Text(selectedTemplate == .quick
                        ? "3 prompts — quick end-of-day capture."
                        : "10 prompts — deeper end-of-day reflection.")
                }
            }
            .navigationTitle("New Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        createReflection()
                        dismiss()
                    }
                }
            }
        }
    }

    private func createReflection() {
        let reflection = Reflection(date: Date(), templateName: selectedTemplate.rawValue)
        context.insert(reflection)
        for (index, prompt) in selectedTemplate.prompts.enumerated() {
            let answer = ReflectionAnswer(
                promptText: prompt,
                displayOrder: index,
                templateName: selectedTemplate.rawValue
            )
            context.insert(answer)
            reflection.answers.append(answer)
        }
    }
}

#Preview {
    StartReflectionView()
        .modelContainer(for: [Reflection.self, ReflectionAnswer.self], inMemory: true)
}
