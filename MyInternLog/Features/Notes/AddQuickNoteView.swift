import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

struct AddQuickNoteView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Tag.name) private var allTags: [Tag]
    @Query(sort: \KnowledgeItem.name) private var allKnowledgeItems: [KnowledgeItem]
    @Query(sort: \ProjectGroup.name) private var allGroups: [ProjectGroup]

    @State private var title = ""
    @State private var noteBody = ""
    @State private var selectedTag: NoteTag = .general
    @State private var highlightType: HighlightType?
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var pendingFiles: [(data: Data, ext: String, name: String)] = []
    @State private var selectedTagNames: Set<String> = []
    @State private var selectedSkillNames: Set<String> = []
    @State private var selectedGroup: ProjectGroup?
    @State private var showingCamera = false
    @State private var showingFileImporter = false

    // Includes anything the user just typed via AddChipField, not only
    // already-persisted Tags/KnowledgeItems, so a freshly-added chip shows
    // up immediately instead of silently vanishing until the note is saved.
    private var tagOptions: [String] {
        Array(Set(Tag.starterSuggestions + allTags.map(\.name) + selectedTagNames)).sorted()
    }

    private var skillOptions: [String] {
        Array(Set(allKnowledgeItems.map(\.name) + selectedSkillNames)).sorted()
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Body (optional)", text: $noteBody, axis: .vertical)
                    .lineLimit(5...)

                Section {
                    Picker("Tag", selection: $selectedTag) {
                        ForEach(NoteTag.allCases, id: \.self) { tag in
                            Text(tag.label).tag(tag)
                        }
                    }
                    Picker("Highlight", selection: $highlightType) {
                        Text("None").tag(HighlightType?.none)
                        ForEach(HighlightType.allCases, id: \.self) { type in
                            Text(type.label).tag(HighlightType?.some(type))
                        }
                    }
                }

                Section("Tags") {
                    ChipFlowPicker(allOptions: tagOptions, selected: $selectedTagNames, chipColor: .blue)
                    AddChipField(placeholder: "New tag") { newTag in
                        selectedTagNames.insert(newTag.lowercased())
                    }
                }

                Section("Skills / Tools / Concepts") {
                    ChipFlowPicker(allOptions: skillOptions, selected: $selectedSkillNames, chipColor: .purple)
                    AddChipField(placeholder: "New skill, tool, or concept") { newItem in
                        selectedSkillNames.insert(newItem)
                    }
                }

                Section("Project Group") {
                    Picker("Group", selection: $selectedGroup) {
                        Text("None").tag(ProjectGroup?.none)
                        ForEach(allGroups.filter { !$0.isArchived }) { group in
                            Text(group.name).tag(ProjectGroup?.some(group))
                        }
                    }
                }

                Section("Attachments") {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
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

                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selectedImages.indices, id: \.self) { index in
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 72, height: 72)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    if !pendingFiles.isEmpty {
                        ForEach(pendingFiles.indices, id: \.self) { index in
                            Label(pendingFiles[index].name, systemImage: "doc.fill")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onChange(of: selectedPhotos) { _, newItems in
                Task {
                    var images: [UIImage] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            images.append(image)
                        }
                    }
                    selectedImages = images
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraCapture { image in
                    selectedImages.append(image)
                }
                .ignoresSafeArea()
            }
            .onAppear { ProjectGroup.ensureDefault(in: context) }
            .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.pdf], allowsMultipleSelection: true) { result in
                if let urls = try? result.get() {
                    for url in urls {
                        guard url.startAccessingSecurityScopedResource() else { continue }
                        defer { url.stopAccessingSecurityScopedResource() }
                        if let data = try? Data(contentsOf: url) {
                            pendingFiles.append((data: data, ext: url.pathExtension, name: url.lastPathComponent))
                        }
                    }
                }
            }
        }
    }

    private func saveNote() {
        let dailyLog = DailyLog.findOrCreate(for: Date(), in: context)

        let note = QuickNote(title: title, body: noteBody, tag: selectedTag)
        note.highlightType = highlightType
        note.dailyLog = dailyLog
        note.tags = selectedTagNames.map { Tag.findOrCreate(named: $0, in: context) }
        note.knowledgeItems = selectedSkillNames.map { KnowledgeItem.findOrCreate(named: $0, category: .concept, in: context) }
        if let selectedGroup {
            note.projectGroups = [selectedGroup]
        }
        context.insert(note)

        for image in selectedImages {
            if let fileName = AttachmentStorage.save(image) {
                let item = AttachmentItem(fileName: fileName, fileType: "image/jpeg", localPath: fileName)
                item.dailyLog = dailyLog
                context.insert(item)
                note.attachments.append(item)
            }
        }
        for file in pendingFiles {
            if let fileName = AttachmentStorage.save(fileData: file.data, preferredExtension: file.ext) {
                let item = AttachmentItem(fileName: file.name, fileType: "application/pdf", localPath: fileName)
                item.dailyLog = dailyLog
                context.insert(item)
                note.attachments.append(item)
            }
        }
        dismiss()
    }
}

#Preview {
    AddQuickNoteView()
        .modelContainer(for: [QuickNote.self, AttachmentItem.self, Tag.self, KnowledgeItem.self, ProjectGroup.self], inMemory: true)
}
