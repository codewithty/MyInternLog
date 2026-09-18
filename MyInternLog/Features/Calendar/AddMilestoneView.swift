import SwiftUI
import SwiftData

struct AddMilestoneView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private var existingMilestone: Milestone?

    @State private var title = ""
    @State private var date: Date
    @State private var type: MilestoneType = .presentation
    @State private var notes = ""
    @State private var reminderOption: MilestoneReminderOption = .none
    @State private var permissionDenied = false
    @State private var showingDeleteConfirmation = false

    // Seeds state directly from either the calendar's currently-viewed month
    // (new milestone) or the milestone being edited, rather than relying on
    // onAppear, which can race the sheet's presentation animation.
    init(defaultDate: Date = Date()) {
        self.existingMilestone = nil
        _date = State(initialValue: defaultDate)
    }

    init(editing milestone: Milestone) {
        self.existingMilestone = milestone
        _title = State(initialValue: milestone.title)
        _date = State(initialValue: milestone.date)
        _type = State(initialValue: milestone.type)
        _notes = State(initialValue: milestone.notes)
        _reminderOption = State(initialValue: milestone.reminderOption ?? .none)
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
                Picker("Reminder", selection: $reminderOption) {
                    ForEach(MilestoneReminderOption.allCases, id: \.self) { option in
                        Text(option.label).tag(option)
                    }
                }

                if existingMilestone != nil {
                    Section {
                        Button("Delete Milestone", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle(existingMilestone == nil ? "New Milestone" : "Edit Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Notifications Disabled", isPresented: $permissionDenied) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("The milestone was saved, but enable notifications in Settings to get a reminder for it.")
            }
            .alert("Delete this milestone?", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let existingMilestone {
                        context.delete(existingMilestone)
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This can't be undone.")
            }
        }
    }

    private func save() {
        let milestone = existingMilestone ?? Milestone(title: title, date: date, type: type, notes: notes)
        milestone.title = title
        milestone.date = date
        milestone.type = type
        milestone.notes = notes
        milestone.reminderOption = reminderOption
        milestone.updatedAt = Date()
        if existingMilestone == nil {
            context.insert(milestone)
        }

        if reminderOption != .none {
            Task {
                let granted = await NotificationService.requestAuthorizationIfNeeded()
                if granted {
                    NotificationService.scheduleMilestoneReminder(milestone)
                    dismiss()
                } else {
                    permissionDenied = true
                }
            }
        } else {
            dismiss()
        }
    }
}

#Preview {
    AddMilestoneView()
        .modelContainer(for: Milestone.self, inMemory: true)
}
