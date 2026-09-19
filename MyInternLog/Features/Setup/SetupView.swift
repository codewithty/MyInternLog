import SwiftUI
import SwiftData

// First-run setup. Every field is optional and the whole flow can be
// skipped — the user should be able to start logging immediately.
struct SetupView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var onFinish: () -> Void = {}

    @State private var title = ""
    @State private var organization = ""
    @State private var location = ""
    @State private var mentorName = ""
    @State private var schoolProgram = ""

    @State private var hasStartDate = false
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date()
    @State private var hasPresentationDate = false
    @State private var presentationDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Before you start") {
                    Label(PrivacyNotice.storage, systemImage: "lock.shield")
                    Label(PrivacyNotice.caution, systemImage: "exclamationmark.triangle")
                    Label(PrivacyNotice.aiExport, systemImage: "doc.on.clipboard")
                }
                .font(.footnote)

                Section("About Your Role") {
                    TextField("Title (e.g. Intern, Research Assistant)", text: $title)
                    TextField("Organization", text: $organization)
                    TextField("Location", text: $location)
                }

                Section("Dates") {
                    Toggle("Set start date", isOn: $hasStartDate.animation())
                    if hasStartDate {
                        DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                    }
                    Toggle("Set end date", isOn: $hasEndDate.animation())
                    if hasEndDate {
                        DatePicker("End date", selection: $endDate, displayedComponents: .date)
                    }
                    Toggle("Set presentation date", isOn: $hasPresentationDate.animation())
                    if hasPresentationDate {
                        DatePicker("Presentation date", selection: $presentationDate, displayedComponents: .date)
                    }
                }

                Section("Mentor & School") {
                    TextField("Mentor / supervisor name", text: $mentorName)
                    TextField("School / program", text: $schoolProgram)
                }

                Section {
                    Text("You can fill this in later from Settings. Nothing here is required to start logging.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Set Up MyInternLog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { finish() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        let profile = InternshipProfile.current(in: context)
        profile.title = title
        profile.organization = organization
        profile.location = location
        profile.mentorName = mentorName
        profile.schoolProgram = schoolProgram
        profile.startDate = hasStartDate ? startDate : nil
        profile.endDate = hasEndDate ? endDate : nil
        profile.presentationDate = hasPresentationDate ? presentationDate : nil
        finish()
    }

    private func finish() {
        onFinish()
        dismiss()
    }
}

#Preview {
    SetupView()
        .modelContainer(for: InternshipProfile.self, inMemory: true)
}
