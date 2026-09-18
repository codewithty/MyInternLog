import SwiftUI
import SwiftData

struct SearchView: View {
    @Query private var notes: [QuickNote]
    @Query private var studyItems: [StudyItem]
    @Query private var reflections: [Reflection]
    @Query private var attachments: [AttachmentItem]
    @Query private var milestones: [Milestone]
    @Query private var careerOutputs: [CareerOutput]

    @State private var searchText = ""
    @State private var filters = SearchFilters()
    @State private var showingFilters = false
    @AppStorage("recentSearches") private var recentSearchesRaw = ""

    private var recentSearches: [String] {
        recentSearchesRaw.isEmpty ? [] : recentSearchesRaw.components(separatedBy: "\u{1}")
    }

    private func dailyLogConfidenceMatches(_ log: DailyLog?) -> Bool {
        filters.confidenceFilter.matches(log?.confidenceValue)
    }

    private var matchingNotes: [QuickNote] {
        guard filters.includes(.notes) else { return [] }
        return notes.filter { note in
            (searchText.isEmpty || note.title.localizedCaseInsensitiveContains(searchText) || note.body.localizedCaseInsensitiveContains(searchText))
            && (!filters.studyLaterOnly || note.tag == .studyLater || note.highlightType == .studyLater)
            && filters.dateFilter.contains(note.dateCreated)
            && dailyLogConfidenceMatches(note.dailyLog)
            && (filters.groupName == nil || note.projectGroups.contains { $0.name == filters.groupName })
            && (filters.skillName == nil || note.knowledgeItems.contains { $0.name == filters.skillName })
        }
    }

    // Study items are inherently "study later" material, so the quick filter
    // never hides them — it only narrows the types that lack that concept.
    private var matchingStudyItems: [StudyItem] {
        guard filters.includes(.studyItems) else { return [] }
        return studyItems.filter {
            (searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) || $0.notes.localizedCaseInsensitiveContains(searchText))
            && filters.dateFilter.contains($0.dateAdded)
        }
    }

    private var matchingReflections: [Reflection] {
        guard filters.includes(.reflections), !filters.studyLaterOnly else { return [] }
        return reflections.filter { reflection in
            (searchText.isEmpty || reflection.answers.contains {
                $0.answerText.localizedCaseInsensitiveContains(searchText) || $0.promptText.localizedCaseInsensitiveContains(searchText)
            })
            && filters.dateFilter.contains(reflection.date)
            && dailyLogConfidenceMatches(reflection.dailyLog)
        }
    }

    private var matchingAttachments: [AttachmentItem] {
        guard filters.includes(.attachments), !filters.studyLaterOnly else { return [] }
        return attachments.filter {
            (searchText.isEmpty || $0.caption.localizedCaseInsensitiveContains(searchText) || $0.notes.localizedCaseInsensitiveContains(searchText) || $0.fileName.localizedCaseInsensitiveContains(searchText))
            && filters.dateFilter.contains($0.createdAt)
        }
    }

    private var matchingMilestones: [Milestone] {
        guard filters.includes(.milestones), !filters.studyLaterOnly else { return [] }
        return milestones.filter {
            (searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) || $0.notes.localizedCaseInsensitiveContains(searchText))
            && filters.dateFilter.contains($0.date)
        }
    }

    private var matchingCareerOutputs: [CareerOutput] {
        guard filters.includes(.careerOutputs), !filters.studyLaterOnly else { return [] }
        return careerOutputs.filter {
            searchText.isEmpty || $0.text.localizedCaseInsensitiveContains(searchText) || $0.targetRole.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var hasNoResults: Bool {
        matchingNotes.isEmpty && matchingStudyItems.isEmpty && matchingReflections.isEmpty
            && matchingAttachments.isEmpty && matchingMilestones.isEmpty && matchingCareerOutputs.isEmpty
    }

    private var isSearchActive: Bool {
        !searchText.isEmpty || !filters.isDefault
    }

    var body: some View {
        NavigationStack {
            Group {
                if !isSearchActive {
                    idleState
                } else if hasNoResults {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    resultsList
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search notes, reflections, study items")
            .onSubmit(of: .search) { saveRecentSearch(searchText) }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: filters.isDefault ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                SearchFilterSheet(filters: $filters)
            }
        }
    }

    private var idleState: some View {
        VStack(spacing: 24) {
            if !recentSearches.isEmpty {
                VStack(alignment: .leading) {
                    Text("Recent Searches").font(.headline).padding(.horizontal)
                    ForEach(recentSearches, id: \.self) { term in
                        Button {
                            searchText = term
                        } label: {
                            Label(term, systemImage: "clock.arrow.circlepath")
                        }
                        .padding(.horizontal)
                    }
                }
            }
            ContentUnavailableView(
                "Search Your Internship",
                systemImage: "magnifyingglass",
                description: Text("Find notes, study items, reflections, attachments, milestones, and career outputs.")
            )
        }
    }

    private var resultsList: some View {
        List {
            if !matchingNotes.isEmpty {
                Section("Notes") {
                    ForEach(matchingNotes) { note in SearchNoteRow(note: note) }
                }
            }
            if !matchingStudyItems.isEmpty {
                Section("Study Items") {
                    ForEach(matchingStudyItems) { item in SearchStudyItemRow(item: item) }
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
            if !matchingAttachments.isEmpty {
                Section("Attachments") {
                    ForEach(matchingAttachments) { attachment in
                        NavigationLink(destination: AttachmentViewerView(attachment: attachment)) {
                            Label(attachment.caption.isEmpty ? attachment.fileName : attachment.caption, systemImage: "paperclip")
                        }
                    }
                }
            }
            if !matchingMilestones.isEmpty {
                Section("Milestones") {
                    ForEach(matchingMilestones) { milestone in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(milestone.title).font(.headline)
                            Text(milestone.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            if !matchingCareerOutputs.isEmpty {
                Section("Career Outputs") {
                    ForEach(matchingCareerOutputs) { output in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(output.outputType.label).font(.headline)
                            Text(output.text).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        }
                    }
                }
            }
        }
    }

    private func saveRecentSearch(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var updated = recentSearches.filter { $0 != trimmed }
        updated.insert(trimmed, at: 0)
        recentSearchesRaw = updated.prefix(8).joined(separator: "\u{1}")
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
        .modelContainer(for: [QuickNote.self, StudyItem.self, Reflection.self, ReflectionAnswer.self, AttachmentItem.self, Milestone.self, CareerOutput.self], inMemory: true)
}
