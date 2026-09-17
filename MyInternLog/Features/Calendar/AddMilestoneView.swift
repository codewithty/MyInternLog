import SwiftUI
import SwiftData

struct AddMilestoneView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var date: Date
    @State private var type: MilestoneType = .presentation
    @State private var notes = ""

    // Seeds the date picker directly from the calendar's currently-viewed
    // month, rather than relying on onAppear (which can race the sheet's
    // presentation animation).
    init(defaultDate: Date = Date()) {
        _date = State(initialValue: defaultDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Picker("Type", selection: $type) {
                    ForEach(MilestoneType.allCases, id: \.self) { type in
                        Text(type.label).tag(type)
                    }
                }
                TextField("Notes (optional)", text: $notes, axis: .vertical)
                    .lineLimit(3...)
            }
            .navigationTitle("New Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let milestone = Milestone(title: title, date: date, type: type, notes: notes)
                        context.insert(milestone)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddMilestoneView()
        .modelContainer(for: Milestone.self, inMemory: true)
}
