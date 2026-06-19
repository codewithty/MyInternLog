import SwiftUI
import SwiftData
import PhotosUI

struct AddQuickNoteView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var noteBody = ""
    @State private var selectedTag: NoteTag = .general
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Body (optional)", text: $noteBody, axis: .vertical)
                    .lineLimit(5...)

                Section {
                    Picker("Tag", selection: $selectedTag) {
                        ForEach(NoteTag.allCases, id: \.self) { tag in
                            Text(tag.rawValue.capitalized).tag(tag)
                        }
                    }
                }

                Section {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Label("Add Photos", systemImage: "photo.badge.plus")
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
        }
    }

    private func saveNote() {
        let note = QuickNote(title: title, body: noteBody, tag: selectedTag)
        context.insert(note)
        for image in selectedImages {
            if let fileName = AttachmentStorage.save(image) {
                let item = AttachmentItem(
                    fileName: fileName,
                    fileType: "image/jpeg",
                    localPath: fileName
                )
                context.insert(item)
                note.attachments.append(item)
            }
        }
        dismiss()
    }
}

#Preview {
    AddQuickNoteView()
        .modelContainer(for: [QuickNote.self, AttachmentItem.self], inMemory: true)
}
