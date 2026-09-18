import SwiftUI
import SwiftData

struct ProjectGroupsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ProjectGroup.name) private var groups: [ProjectGroup]
    @State private var showingAdd = false

    var body: some View {
        let activeGroups = groups.filter { !$0.isArchived }
        let archivedGroups = groups.filter(\.isArchived)

        List {
            Section("Active") {
                ForEach(activeGroups) { group in
                    GroupRow(group: group)
                }
                .onDelete { offsets in deleteGroups(activeGroups, at: offsets) }
            }
            if !archivedGroups.isEmpty {
                Section("Archived") {
                    ForEach(archivedGroups) { group in
                        GroupRow(group: group)
                    }
                    .onDelete { offsets in deleteGroups(archivedGroups, at: offsets) }
                }
            }
        }
        .navigationTitle("Project Groups")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear { ProjectGroup.ensureDefault(in: context) }
        .sheet(isPresented: $showingAdd) {
            AddProjectGroupView()
        }
    }

    private func deleteGroups(_ source: [ProjectGroup], at offsets: IndexSet) {
        for index in offsets {
            context.delete(source[index])
        }
    }
}

private struct GroupRow: View {
    @Bindable var group: ProjectGroup

    var body: some View {
        HStack {
            Image(systemName: group.iconName)
                .foregroundStyle(Color.named(group.colorName))
            Text(group.name)
            Spacer()
            Button(group.isArchived ? "Unarchive" : "Archive") {
                group.isArchived.toggle()
                group.updatedAt = Date()
            }
            .font(.caption)
        }
    }
}

private struct AddProjectGroupView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var colorName = "blue"
    @State private var iconName = "folder.fill"

    private let colorOptions = ["blue", "purple", "green", "orange", "pink", "teal", "red", "indigo"]
    private let iconOptions = ["folder.fill", "briefcase.fill", "flask.fill", "hammer.fill", "chart.bar.fill", "book.fill"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Group name", text: $name)

                Section("Color") {
                    ChipFlowPicker(
                        allOptions: colorOptions,
                        selected: Binding(
                            get: { [colorName] },
                            set: { if let first = $0.first { colorName = first } }
                        ),
                        chipColor: Color.named(colorName)
                    )
                }

                Section("Icon") {
                    Picker("Icon", selection: $iconName) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Label(icon, systemImage: icon).tag(icon)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        context.insert(ProjectGroup(name: name, colorName: colorName, iconName: iconName))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectGroupsListView()
            .modelContainer(for: ProjectGroup.self, inMemory: true)
    }
}
