import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

// Edits an existing note in place. Every field writes straight to the
// @Bindable note, so changes autosave via SwiftData as soon as they're made —
// there's no separate "Save" step, matching how daily logs are meant to
// autosave throughout the app.
struct QuickNoteDetailView: View {
    @Bindable var note: QuickNote
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Tag.name) private var allTags: [Tag]
    @Query(sort: \KnowledgeItem.name) private var allKnowledgeItems: [KnowledgeItem]
    @Query(sort: \ProjectGroup.name) private var allGroups: [ProjectGroup]

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingCamera = false
    @State private var showingFileImporter = false
    @State private var showingDeleteConfirmation = false

    private var tagOptions: [String] {
        Array(Set(Tag.starterSuggestions + allTags.map(\.name) + note.tags.map(\.name))).sorted()
    }

    private var skillOptions: [String] {
        Array(Set(allKnowledgeItems.map(\.name) + note.knowledgeItems.map(\.name))).sorted()
    }

    private var tagNamesBinding: Binding<Set<String>> {
        Binding(
            get: { Set(note.tags.map(\.name)) },
            set: { newNames in note.tags = newNames.map { Tag.findOrCreate(named: $0, in: context) } }
        )
    }

    private var skillNamesBinding: Binding<Set<String>> {
        Binding(
            get: { Set(note.knowledgeItems.map(\.name)) },
            set: { newNames in note.knowledgeItems = newNames.map { KnowledgeItem.findOrCreate(named: $0, category: .concept, in: context) } }
        )
    }

    private var groupBinding: Binding<ProjectGroup?> {
        Binding(
            get: { note.projectGroups.first },
            set: { newGroup in note.projectGroups = newGroup.map { [$0] } ?? [] }
        )
    }

    var body: some View {
        Form {
            TextField("Title", text: $note.title)
            TextField("Body (optional)", text: $note.body, axis: .vertical)
                .lineLimit(5...)

            Section {
                Picker("Tag", selection: $note.tag) {
                    ForEach(NoteTag.allCases, id: \.self) { tag in
                        Text(tag.label).tag(tag)
                    }
                }
                Picker("Highlight", selection: $note.highlightType) {
                    Text("None").tag(HighlightType?.none)
                    ForEach(HighlightType.allCases, id: \.self) { type in
                        Text(type.label).tag(HighlightType?.some(type))
                    }
                }
            }

            Section("Tags") {
                ChipFlowPicker(allOptions: tagOptions, selected: tagNamesBinding, chipColor: .blue)
                AddChipField(placeholder: "New tag") { newTag in
                    tagNamesBinding.wrappedValue.insert(newTag.lowercased())
                }
            }

            Section("Skills / Tools / Concepts") {
                ChipFlowPicker(allOptions: skillOptions, selected: skillNamesBinding, chipColor: .purple)
                AddChipField(placeholder: "New skill, tool, or concept") { newItem in
                    skillNamesBinding.wrappedValue.insert(newItem)
                }
            }

            Section("Project Group") {
                Picker("Group", selection: groupBinding) {
                    Text("None").tag(ProjectGroup?.none)
                    ForEach(allGroups.filter { !$0.isArchived }) { group in
                        Text(group.name).tag(ProjectGroup?.some(group))
                    }
                }
            }

            Section("Attachments") {
                if !note.attachments.isEmpty {
                    ForEach(note.attachments) { attachment in
                        AttachmentEditRow(attachment: attachment) {
                            note.attachments.removeAll { $0.id == attachment.id }
                            context.delete(attachment)
                        }
                    }
                }

                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10, matching: .images) {
                    Label("Add Photos", systemImage: "photo.badge.plus")
                }
                Button {
                    showingCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                }
                Button {
                    showingFileImporter = true
                } label: {
                    Label("Add File", systemImage: "doc.badge.plus")
                }
            }

            Section {
                Button("Delete Note", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
        .navigationTitle("Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        .onChange(of: selectedPhotos) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data),
                       let fileName = AttachmentStorage.save(image) {
                        let attachment = AttachmentItem(fileName: fileName, fileType: "image/jpeg", localPath: fileName)
                        attachment.dailyLog = note.dailyLog
                        context.insert(attachment)
                        note.attachments.append(attachment)
                    }
                }
                selectedPhotos = []
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraCapture { image in
                if let fileName = AttachmentStorage.save(image) {
                    let attachment = AttachmentItem(fileName: fileName, fileType: "image/jpeg", localPath: fileName)
                    attachment.dailyLog = note.dailyLog
                    context.insert(attachment)
                    note.attachments.append(attachment)
                }
            }
            .ignoresSafeArea()
        }
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.pdf], allowsMultipleSelection: true) { result in
            if let urls = try? result.get() {
                for url in urls {
                    guard url.startAccessingSecurityScopedResource() else { continue }
                    defer { url.stopAccessingSecurityScopedResource() }
                    if let data = try? Data(contentsOf: url),
                       let fileName = AttachmentStorage.save(fileData: data, preferredExtension: url.pathExtension) {
                        let attachment = AttachmentItem(fileName: fileName, fileType: "application/pdf", localPath: fileName)
                        attachment.dailyLog = note.dailyLog
                        context.insert(attachment)
                        note.attachments.append(attachment)
                    }
                }
            }
        }
        .alert("Delete this note?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                context.delete(note)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
    }
}

private struct AttachmentEditRow: View {
    @Bindable var attachment: AttachmentItem
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if attachment.fileType.hasPrefix("image"), let image = AttachmentStorage.load(fileName: attachment.localPath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Image(systemName: "doc.fill")
                        .frame(width: 44, height: 44)
                }
                TextField("Caption (optional)", text: $attachment.caption)
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text("Tap a note in the list to edit it.")
    }
}
