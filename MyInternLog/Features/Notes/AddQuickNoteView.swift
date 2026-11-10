import SwiftUI
import SwiftData
import PhotosUI

// Quick capture: tap + and start typing. The first line becomes the title and
// the rest becomes the body. Only the things that matter in the moment are
// here (a kind tag that the resume bullet generator uses, and photos).
// Everything else (tags, skills, project group, highlight, files) is edited
// later in QuickNoteDetailView.
struct AddQuickNoteView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var kind: NoteTag = .general
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showingCamera = false
    @FocusState private var isTyping: Bool

    // The kinds worth one tap while capturing. They decide what the bullet
    // generator keeps (wins) and skips (blockers, questions, ideas).
    private let quickKinds: [NoteTag] = [.win, .blocker, .question, .idea]

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedImages.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("What did you just do?")
                            .font(.title3)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $text)
                        .font(.title3)
                        .focused($isTyping)
                        .scrollContentBackground(.hidden)
                }
                .padding(.horizontal)

                if !selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(selectedImages.indices, id: \.self) { index in
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }

                captureBar
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveNote() }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
            // Keyboard is up the moment the sheet opens.
            .task { isTyping = true }
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
        }
    }

    // One row above the keyboard: kind chips, then photo buttons.
    private var captureBar: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickKinds, id: \.self) { option in
                        let isOn = kind == option
                        Button {
                            // Tap again to clear it back to a plain note.
                            kind = isOn ? .general : option
                        } label: {
                            Text(option.label)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(isOn ? Color.accentColor : Color(.secondarySystemFill), in: Capsule())
                                .foregroundStyle(isOn ? Color.white : Color.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10, matching: .images) {
                Image(systemName: "photo")
                    .font(.title3)
                    .frame(width: 36, height: 36)
            }
            Button {
                showingCamera = true
            } label: {
                Image(systemName: "camera")
                    .font(.title3)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private func saveNote() {
        let parts = QuickCaptureParser.split(text)
        // A photo-only note still needs a title to show in lists.
        let title = parts.title.isEmpty ? "Photo" : parts.title

        let dailyLog = DailyLog.findOrCreate(for: Date(), in: context)
        let note = QuickNote(title: title, body: parts.body, tag: kind)
        note.dailyLog = dailyLog
        context.insert(note)

        for image in selectedImages {
            if let fileName = AttachmentStorage.save(image) {
                let item = AttachmentItem(fileName: fileName, fileType: "image/jpeg", localPath: fileName)
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
        .modelContainer(for: AppSchema.models, inMemory: true)
}
