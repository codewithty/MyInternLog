import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context

    @AppStorage("appTheme") private var appThemeRawValue = AppTheme.system.rawValue
    @AppStorage("requireDraftApproval") private var requireDraftApproval = false
    @State private var showingAbout = false
    @State private var exportedFile: IdentifiableURL?
    @State private var showingExportError = false
    @State private var exportErrorMessage = ""

    private let demoMode = DemoMode.shared

    private var profile: InternshipProfile {
        InternshipProfile.current(in: context)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Role") {
                    TextField("Title", text: bindingFor(\.title))
                    TextField("Organization", text: bindingFor(\.organization))
                    TextField("Location", text: bindingFor(\.location))
                    TextField("Mentor / supervisor", text: bindingFor(\.mentorName))
                    TextField("Mentor email (optional)", text: bindingFor(\.mentorEmail))
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Mentor phone (optional)", text: bindingFor(\.mentorPhone))
                        .keyboardType(.phonePad)
                    TextField("School / program", text: bindingFor(\.schoolProgram))
                    TextField("Notes (optional)", text: bindingFor(\.notes), axis: .vertical)
                        .lineLimit(3...)
                }

                Section("Dates") {
                    optionalDatePicker("Start date", date: bindingForOptional(\.startDate))
                    optionalDatePicker("End date", date: bindingForOptional(\.endDate))
                    optionalDatePicker("Presentation date", date: bindingForOptional(\.presentationDate))
                }

                Section("Home Screen") {
                    Toggle("Show week number", isOn: bindingFor(\.showWeekNumber))
                }

                Section {
                    NavigationLink("Reminders") {
                        RemindersView()
                    }
                    NavigationLink("Project Groups") {
                        ProjectGroupsListView()
                    }
                }

                Section {
                    Toggle("Require approval before filling suggested drafts", isOn: $requireDraftApproval)
                } header: {
                    Text("Summary Draft Builder")
                } footer: {
                    Text("When off, \"Suggest Draft\" fills empty reflection prompts automatically from today's notes. When on, you review each suggestion first.")
                }

                Section {
                    Toggle("Use generic wording by default", isOn: bindingFor(\.useGenericWordingByDefault))
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("Applies to AI prompt exports and PDF reports so lab/project specifics stay out by default.")
                }

                Section {
                    Button("Export All Data (JSON)", systemImage: "square.and.arrow.up", action: exportData)
                        .disabled(demoMode.isOn)
                } header: {
                    Text("Your Data")
                } footer: {
                    Text("A complete copy of your notes, reflections, milestones, and settings as a readable file. Photos and PDFs aren't included, and the file can't be re-imported yet.")
                }

                Section {
                    Toggle("Demo mode", isOn: Bindable(demoMode).isOn)
                } header: {
                    Text("Demo")
                } footer: {
                    Text("Explore the app filled with sample data. Nothing you do in demo mode is saved, and your real entries are never touched.")
                }

                Section("Appearance") {
                    Picker("Theme", selection: $appThemeRawValue) {
                        ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                            Text(theme.label).tag(theme.rawValue)
                        }
                    }
                }

                Section {
                    Button("About MyInternLog") {
                        showingAbout = true
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(item: $exportedFile) { file in
                ShareSheet(items: [file.url])
            }
            .alert("Couldn't Export", isPresented: $showingExportError) { } message: {
                Text(exportErrorMessage)
            }
        }
    }

    private func exportData() {
        do {
            exportedFile = IdentifiableURL(url: try DataExporter.writeExportFile(from: context))
        } catch {
            exportErrorMessage = error.localizedDescription
            showingExportError = true
        }
    }

    // Small helper so each Form row can bind straight to a profile field
    // without hand-writing a getter/setter for every one.
    private func bindingFor(_ keyPath: ReferenceWritableKeyPath<InternshipProfile, String>) -> Binding<String> {
        Binding(
            get: { profile[keyPath: keyPath] },
            set: { profile[keyPath: keyPath] = $0 }
        )
    }

    private func bindingFor(_ keyPath: ReferenceWritableKeyPath<InternshipProfile, Bool>) -> Binding<Bool> {
        Binding(
            get: { profile[keyPath: keyPath] },
            set: { profile[keyPath: keyPath] = $0 }
        )
    }

    private func bindingForOptional(_ keyPath: ReferenceWritableKeyPath<InternshipProfile, Date?>) -> Binding<Date?> {
        Binding(
            get: { profile[keyPath: keyPath] },
            set: { profile[keyPath: keyPath] = $0 }
        )
    }

    @ViewBuilder
    private func optionalDatePicker(_ label: String, date: Binding<Date?>) -> some View {
        Toggle(label, isOn: Binding(
            get: { date.wrappedValue != nil },
            set: { isOn in date.wrappedValue = isOn ? Date() : nil }
        ))
        if let unwrapped = date.wrappedValue {
            DatePicker(
                label,
                selection: Binding(get: { unwrapped }, set: { date.wrappedValue = $0 }),
                displayedComponents: .date
            )
            .labelsHidden()
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: InternshipProfile.self, inMemory: true)
}
