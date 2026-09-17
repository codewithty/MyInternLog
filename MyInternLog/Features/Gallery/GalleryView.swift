import SwiftUI
import SwiftData

struct GalleryView: View {
    @Query(sort: \AttachmentItem.createdAt, order: .reverse) private var attachments: [AttachmentItem]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

    var body: some View {
        NavigationStack {
            ScrollView {
                if attachments.isEmpty {
                    ContentUnavailableView("No Attachments Yet", systemImage: "photo.on.rectangle")
                        .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(attachments) { attachment in
                            NavigationLink(destination: AttachmentViewerView(attachment: attachment)) {
                                GalleryThumbnail(attachment: attachment)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Gallery")
        }
    }
}

private struct GalleryThumbnail: View {
    let attachment: AttachmentItem

    var body: some View {
        Group {
            if let image = AttachmentStorage.load(fileName: attachment.localPath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .clipped()
    }
}

struct AttachmentViewerView: View {
    let attachment: AttachmentItem

    @State private var scale: CGFloat = 1.0

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            if let image = AttachmentStorage.load(fileName: attachment.localPath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in scale = value }
                            .onEnded { _ in
                                withAnimation { scale = max(1.0, min(scale, 4.0)) }
                            }
                    )
            } else {
                ContentUnavailableView("Couldn't Load Image", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(attachment.caption.isEmpty ? "Attachment" : attachment.caption)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    GalleryView()
        .modelContainer(for: AttachmentItem.self, inMemory: true)
}
