import SwiftUI
import SwiftData

struct SearchFilterSheet: View {
    @Binding var filters: SearchFilters
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \ProjectGroup.name) private var groups: [ProjectGroup]
    @Query(sort: \KnowledgeItem.name) private var knowledgeItems: [KnowledgeItem]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(SearchResultType.allCases) { type in
                        Toggle(type.rawValue, isOn: Binding(
                            get: { filters.activeTypes.contains(type) },
                            set: { isOn in
                                if isOn { filters.activeTypes.insert(type) } else { filters.activeTypes.remove(type) }
                            }
                        ))
                    }
                } header: {
                    Text("Types")
                } footer: {
                    Text("Leave all off to search everything.")
                }

                Section("Quick Filters") {
                    Toggle("Study Later only", isOn: $filters.studyLaterOnly)
                }

                Section("Date") {
                    Picker("Date", selection: $filters.dateFilter) {
                        ForEach(SearchDateFilter.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("Confidence (that day)") {
                    Picker("Confidence", selection: $filters.confidenceFilter) {
                        ForEach(ConfidenceFilter.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Project Group") {
                    Picker("Group", selection: $filters.groupName) {
                        Text("Any").tag(String?.none)
                        ForEach(groups) { group in
                            Text(group.name).tag(String?.some(group.name))
                        }
                    }
                }

                Section("Skill / Tool / Concept") {
                    Picker("Skill", selection: $filters.skillName) {
                        Text("Any").tag(String?.none)
                        ForEach(knowledgeItems) { item in
                            Text(item.name).tag(String?.some(item.name))
                        }
                    }
                }

                Section {
                    Button("Reset Filters") { filters = SearchFilters() }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
