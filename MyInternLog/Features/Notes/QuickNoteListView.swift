import SwiftUI
import SwiftData

struct QuickNoteListView: View {
    @Query(sort: \QuickNote.dateCreated, order: .reverse) private var notes: [QuickNote]
    @State private var showingAddNote = false

    var body: some View {
        NavigationStack {
            List(notes) { note in
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                    if !note.body.isEmpty {
                        Text(note.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
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
        }
    }
}

#Preview {
    QuickNoteListView()
        .modelContainer(for: QuickNote.self, inMemory: true)
}
