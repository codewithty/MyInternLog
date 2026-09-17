import SwiftUI

struct EditReminderView: View {
    @Bindable var reminder: ReminderSetting
    var onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        NavigationStack {
            Form {
                TextField("Label", text: $reminder.label)
                TextField("Message", text: $reminder.message, axis: .vertical)
                    .lineLimit(2...)
                DatePicker("Time", selection: $reminder.time, displayedComponents: .hourAndMinute)

                Section("Repeat On") {
                    ForEach(1...7, id: \.self) { weekday in
                        Toggle(weekdaySymbols[weekday - 1], isOn: Binding(
                            get: { reminder.enabledWeekdays.contains(weekday) },
                            set: { isOn in
                                if isOn {
                                    reminder.enabledWeekdays.append(weekday)
                                } else {
                                    reminder.enabledWeekdays.removeAll { $0 == weekday }
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle(reminder.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EditReminderView(reminder: ReminderSetting(label: "Morning capture", message: "Capture your first note.", time: Date()), onSave: {})
}
