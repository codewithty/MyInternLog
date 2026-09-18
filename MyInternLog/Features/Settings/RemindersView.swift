import SwiftUI
import SwiftData

struct RemindersView: View {
    @Environment(\.modelContext) private var context
    @Query private var reminders: [ReminderSetting]

    @State private var permissionDenied = false
    @State private var editingReminder: ReminderSetting?

    var body: some View {
        List {
            Section {
                ForEach(reminders) { reminder in
                    ReminderRow(reminder: reminder, onToggle: { handleToggle(reminder) })
                        .onTapGesture { editingReminder = reminder }
                }
                .onDelete(perform: deleteReminders)
            } footer: {
                Text("Reminders are off by default and never track streaks — they're just a nudge to log.")
            }

            Section {
                Button("Add Reminder") {
                    let reminder = ReminderSetting(label: "Custom reminder", message: "Time to log in MyInternLog.", time: Date())
                    context.insert(reminder)
                    editingReminder = reminder
                }
            }
        }
        .navigationTitle("Reminders")
        .onAppear { ReminderSetting.ensureDefaults(in: context) }
        .sheet(item: $editingReminder) { reminder in
            EditReminderView(reminder: reminder, onSave: { NotificationService.reschedule(reminders) })
        }
        .alert("Notifications Disabled", isPresented: $permissionDenied) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Enable notifications for MyInternLog in the Settings app to use reminders.")
        }
    }

    private func handleToggle(_ reminder: ReminderSetting) {
        if reminder.isEnabled {
            Task {
                let granted = await NotificationService.requestAuthorizationIfNeeded()
                if granted {
                    NotificationService.reschedule(reminders)
                } else {
                    reminder.isEnabled = false
                    permissionDenied = true
                }
            }
        } else {
            NotificationService.reschedule(reminders)
        }
    }

    private func deleteReminders(at offsets: IndexSet) {
        for index in offsets {
            context.delete(reminders[index])
        }
        NotificationService.reschedule(reminders)
    }
}

private struct ReminderRow: View {
    @Bindable var reminder: ReminderSetting
    var onToggle: () -> Void

    private var daysSummary: String {
        if reminder.enabledWeekdays.count == 7 { return "Every day" }
        if reminder.enabledWeekdays.isEmpty { return "No days selected" }
        let symbols = Calendar.current.shortWeekdaySymbols
        return reminder.enabledWeekdays.sorted().map { symbols[$0 - 1] }.joined(separator: ", ")
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.label).font(.headline)
                Text(reminder.time.formatted(date: .omitted, time: .shortened) + " · " + daysSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: $reminder.isEnabled)
                .labelsHidden()
                .onChange(of: reminder.isEnabled) { _, _ in onToggle() }
        }
    }
}

#Preview {
    NavigationStack {
        RemindersView()
            .modelContainer(for: ReminderSetting.self, inMemory: true)
    }
}
