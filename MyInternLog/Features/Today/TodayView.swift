import SwiftUI
import SwiftData

// The daily hub: today's quick notes, attachments, and reflection together
// in one place, reached from Home's "Let's Log" button.
struct TodayView: View {
    @Query(sort: \QuickNote.dateCreated, order: .reverse) private var allNotes: [QuickNote]
    @Query private var allReflections: [Reflection]
    @Query(sort: \AttachmentItem.createdAt, order: .reverse) private var allAttachments: [AttachmentItem]

    @State private var showingAddNote = false
    @State private var showingStartReflection = false
    @State private var editingNote: QuickNote?

    private var todaysNotes: [QuickNote] {
        allNotes.filter { Calendar.current.isDateInToday($0.dateCreated) }
    }

    private var todaysAttachments: [AttachmentItem] {
        allAttachments.filter { Calendar.current.isDateInToday($0.createdAt) }
    }

    private var todaysReflection: Reflection? {
        allReflections.first { Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Reflection") {
                    if let reflection = todaysReflection {
                        NavigationLink(destination: ReflectionDetailView(reflection: reflection)) {
                            HStack {
                                Text(reflection.templateName + " Reflection")
                                Spacer()
                                Text(reflection.isComplete ? "Complete" : "Draft")
                                    .font(.caption)
                                    .foregroundStyle(reflection.isComplete ? .green : .secondary)
                            }
                        }
                    } else {
                        Button {
                            showingStartReflection = true
                        } label: {
                            Label("Start Today's Reflection", systemImage: "text.book.closed")
                        }
                    }
                }

                Section("Quick Notes") {
                    if todaysNotes.isEmpty {
                        Text("No notes yet today.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(todaysNotes) { note in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(note.title).font(.subheadline.bold())
                                if !note.body.isEmpty {
                                    Text(note.body).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { editingNote = note }
                        }
                    }
                    Button {
                        showingAddNote = true
                    } label: {
                        Label("Add Note", systemImage: "plus.circle")
                    }
                }

                if !todaysAttachments.isEmpty {
                    Section("Attachments") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(todaysAttachments) { attachment in
                                    if attachment.fileType.hasPrefix("image"), let image = AttachmentStorage.load(fileName: attachment.localPath) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 64, height: 64)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else {
                                        Image(systemName: "doc.fill")
                                            .frame(width: 64, height: 64)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(Date().formatted(date: .complete, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddNote) {
                AddQuickNoteView()
            }
            .sheet(isPresented: $showingStartReflection) {
                StartReflectionView()
            }
            .sheet(item: $editingNote) { note in
                NavigationStack {
                    QuickNoteDetailView(note: note)
                }
            }
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(SampleData.container)
}
