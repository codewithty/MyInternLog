import SwiftUI
import SwiftData

struct CareerOutputListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CareerOutput.createdAt, order: .reverse) private var outputs: [CareerOutput]
    @State private var showingExport = false
    @State private var editingOutput: CareerOutput?

    private var groupedByType: [(type: CareerOutputType, outputs: [CareerOutput])] {
        CareerOutputType.allCases.compactMap { type in
            let matches = outputs.filter { $0.outputType == type }
            return matches.isEmpty ? nil : (type, matches)
        }
    }

    private func groupedByRole(_ outputs: [CareerOutput]) -> [(role: String, outputs: [CareerOutput])] {
        let roles = Set(outputs.map { $0.targetRole.isEmpty ? "General" : $0.targetRole })
        return roles.sorted().map { role in
            (role, outputs.filter { ($0.targetRole.isEmpty ? "General" : $0.targetRole) == role })
        }
    }

    @ViewBuilder
    private func rows(for outputs: [CareerOutput]) -> some View {
        ForEach(outputs) { output in
            CareerOutputRow(output: output)
                .contentShape(Rectangle())
                .onTapGesture { editingOutput = output }
        }
        .onDelete { offsets in
            for index in offsets {
                context.delete(outputs[index])
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if outputs.isEmpty {
                    ContentUnavailableView(
                        "No Career Outputs Yet",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Export a summary or resume bullets to get started.")
                    )
                } else {
                    List {
                        ForEach(groupedByType, id: \.type) { group in
                            if group.type == .resumeBullet {
                                ForEach(groupedByRole(group.outputs), id: \.role) { roleGroup in
                                    Section("Resume Bullets — " + roleGroup.role) {
                                        rows(for: roleGroup.outputs)
                                    }
                                }
                            } else {
                                Section(group.type.label) {
                                    rows(for: group.outputs)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Career Outputs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingExport = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingExport) {
                PromptExportView()
            }
            .sheet(item: $editingOutput) { output in
                EditCareerOutputView(output: output)
            }
        }
    }
}

private struct EditCareerOutputView: View {
    @Bindable var output: CareerOutput
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Target role (optional)", text: $output.targetRole)
                TextEditor(text: $output.text)
                    .frame(minHeight: 160)
                Toggle("Favorite", isOn: $output.isFavorite)

                Section {
                    Button("Delete", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle(output.outputType.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete this output?", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    context.delete(output)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This can't be undone.")
            }
        }
    }
}

private struct CareerOutputRow: View {
    @Bindable var output: CareerOutput

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if !output.targetRole.isEmpty {
                    Text(output.targetRole)
                        .font(.subheadline.bold())
                }
                Spacer()
                Button {
                    output.isFavorite.toggle()
                } label: {
                    Image(systemName: output.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(output.isFavorite ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
            }
            Text(output.text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            Text(output.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CareerOutputListView()
        .modelContainer(for: CareerOutput.self, inMemory: true)
}
