import SwiftUI
import SwiftData

struct WeeklyRecapView: View {
    @Query(sort: \QuickNote.dateCreated, order: .reverse) private var allNotes: [QuickNote]

    private var recentNotes: [QuickNote] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return allNotes.filter { $0.dateCreated >= cutoff }
    }

    var body: some View {
        NavigationStack {
            List(recentNotes) { note in
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                    if !note.body.isEmpty {
                        Text(note.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Text(note.dateCreated.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .overlay {
                if recentNotes.isEmpty {
                    ContentUnavailableView("No Notes This Week", systemImage: "calendar")
                }
            }
            .navigationTitle("This Week")
        }
    }
}

#Preview {
    WeeklyRecapView()
        .modelContainer(for: QuickNote.self, inMemory: true)
}
