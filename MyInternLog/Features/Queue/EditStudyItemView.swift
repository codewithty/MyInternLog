import SwiftUI
import SwiftData

struct EditStudyItemView: View {
    @Bindable var item: StudyItem
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $item.title)
                TextField("Notes (optional)", text: $item.notes, axis: .vertical)
                    .lineLimit(5...)
                Toggle("Reviewed", isOn: $item.isReviewed)

                Section {
                    Button("Delete Study Item", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Edit Study Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete this study item?", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    context.delete(item)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This can't be undone.")
            }
        }
    }
}

#Preview {
    EditStudyItemView(item: StudyItem(title: "Review FFT basics"))
        .modelContainer(for: StudyItem.self, inMemory: true)
}
