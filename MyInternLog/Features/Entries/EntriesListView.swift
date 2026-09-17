import SwiftUI
import SwiftData

private enum EntryGrouping: String, CaseIterable {
    case none = "None"
    case week = "Week"
    case month = "Month"
}

struct EntriesListView: View {
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var grouping: EntryGrouping = .none
    @State private var selectedLog: DailyLog?

    private var groupedLogs: [(title: String, logs: [DailyLog])] {
        switch grouping {
        case .none:
            return [("All Entries", logs)]
        case .week:
            return group(by: .weekOfYear)
        case .month:
            return group(by: .month)
        }
    }

    private func group(by component: Calendar.Component) -> [(title: String, logs: [DailyLog])] {
        let calendar = Calendar.current
        var buckets: [Date: [DailyLog]] = [:]
        for log in logs {
            let key = calendar.dateInterval(of: component, for: log.date)?.start ?? log.date
            buckets[key, default: []].append(log)
        }
        return buckets.keys.sorted(by: >).map { key in
            let title: String
            if component == .month {
                title = key.formatted(.dateTime.month(.wide).year())
            } else {
                title = "Week of " + key.formatted(date: .abbreviated, time: .omitted)
            }
            return (title, buckets[key] ?? [])
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if logs.isEmpty {
                    ContentUnavailableView("No Entries Yet", systemImage: "archivebox")
                } else {
                    List {
                        ForEach(groupedLogs, id: \.title) { group in
                            Section(group.title) {
                                ForEach(group.logs) { log in
                                    EntryRow(log: log)
                                        .contentShape(Rectangle())
                                        .onTapGesture { selectedLog = log }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Entries")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Picker("Group By", selection: $grouping) {
                        ForEach(EntryGrouping.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
            }
            .sheet(item: $selectedLog) { log in
                DayDetailView(date: log.date, dailyLog: log)
            }
        }
    }
}

private struct EntryRow: View {
    let log: DailyLog

    private var isComplete: Bool {
        log.reflections.contains { $0.isComplete }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(log.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Text("\(log.quickNotes.count) note\(log.quickNotes.count == 1 ? "" : "s") · \(log.reflections.count) reflection\(log.reflections.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if !log.reflections.isEmpty {
                Text(isComplete ? "Complete" : "Draft")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(isComplete ? Color.green.opacity(0.15) : Color.secondary.opacity(0.15))
                    .foregroundStyle(isComplete ? Color.green : Color.secondary)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    EntriesListView()
        .modelContainer(SampleData.container)
}
