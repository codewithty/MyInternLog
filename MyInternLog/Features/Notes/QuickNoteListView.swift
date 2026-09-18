import SwiftUI
import SwiftData

struct QuickNoteListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \QuickNote.dateCreated, order: .reverse) private var notes: [QuickNote]
    @State private var showingAddNote = false
    @State private var editingNote: QuickNote?

    var body: some View {
        NavigationStack {
            List {
                ForEach(notes) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title)
                            .font(.headline)
                        if !note.body.isEmpty {
                            Text(note.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        if !note.attachments.isEmpty {
                            Label(
                                "\(note.attachments.count) photo\(note.attachments.count == 1 ? "" : "s")",
                                systemImage: "photo"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { editingNote = note }
                }
                .onDelete(perform: deleteNotes)
            }
            .overlay {
                if notes.isEmpty {
                    ContentUnavailableView("No Notes Yet", systemImage: "note.text")
                }
            }
            .navigationTitle("Quick Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddQuickNoteView()
            }
            .sheet(item: $editingNote) { note in
                NavigationStack {
                    QuickNoteDetailView(note: note)
                }
            }
        }
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            context.delete(notes[index])
        }
    }
}

#Preview {
    QuickNoteListView()
        .modelContainer(for: QuickNote.self, inMemory: true)
}
