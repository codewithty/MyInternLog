import SwiftUI
import SwiftData

struct AddQuickNoteView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var noteBody = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Body (optional)", text: $noteBody, axis: .vertical)
                    .lineLimit(5...)
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let note = QuickNote(title: title, body: noteBody)
                        context.insert(note)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddQuickNoteView()
        .modelContainer(for: QuickNote.self, inMemory: true)
}
