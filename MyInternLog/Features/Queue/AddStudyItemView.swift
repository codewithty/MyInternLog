import SwiftUI
import SwiftData

struct AddStudyItemView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("What do you want to study?", text: $title)

                TextField("Notes (optional)", text: $notes, axis: .vertical)
                    .lineLimit(5...)
            }
            .navigationTitle("New Study Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = StudyItem(title: title, notes: notes)
                        context.insert(item)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddStudyItemView()
        .modelContainer(for: StudyItem.self, inMemory: true)
}
