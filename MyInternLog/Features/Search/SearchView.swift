import SwiftUI
import SwiftData

struct SearchView: View {
    @Query private var notes: [QuickNote]
    @Query private var studyItems: [StudyItem]
    @Query private var reflections: [Reflection]

    @State private var searchText = ""

    private var matchingNotes: [QuickNote] {
        notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.body.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var matchingStudyItems: [StudyItem] {
        studyItems.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var matchingReflections: [Reflection] {
        reflections.filter { reflection in
            reflection.answers.contains {
                $0.answerText.localizedCaseInsensitiveContains(searchText) ||
                $0.promptText.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private var hasNoResults: Bool {
        matchingNotes.isEmpty && matchingStudyItems.isEmpty && matchingReflections.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    ContentUnavailableView(
                        "Search Your Internship",
                        systemImage: "magnifyingglass",
                        description: Text("Find notes, study items, and reflections.")
                    )
                } else if hasNoResults {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        if !matchingNotes.isEmpty {
                            Section("Notes") {
                                ForEach(matchingNotes) { note in
                                    SearchNoteRow(note: note)
                                }
                            }
                        }
                        if !matchingStudyItems.isEmpty {
                            Section("Study Items") {
                                ForEach(matchingStudyItems) { item in
                                    SearchStudyItemRow(item: item)
                                }
                            }
                        }
                        if !matchingReflections.isEmpty {
                            Section("Reflections") {
                                ForEach(matchingReflections) { reflection in
                                    NavigationLink(destination: ReflectionDetailView(reflection: reflection)) {
                                        SearchReflectionRow(reflection: reflection)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search notes, reflections, study items")
        }
    }
}

private struct SearchNoteRow: View {
    let note: QuickNote

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title).font(.headline)
            if !note.body.isEmpty {
                Text(note.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

private struct SearchStudyItemRow: View {
    let item: StudyItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
                .strikethrough(item.isReviewed)
            if !item.notes.isEmpty {
                Text(item.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

private struct SearchReflectionRow: View {
    let reflection: Reflection

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(reflection.date.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)
            Text(reflection.templateName + " Reflection")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [QuickNote.self, StudyItem.self, Reflection.self, ReflectionAnswer.self], inMemory: true)
}
