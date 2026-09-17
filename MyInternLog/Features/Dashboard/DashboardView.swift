import SwiftUI
import SwiftData
import Charts

private enum DashboardRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case allInternship = "All Internship"

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .allInternship: return 365
        }
    }
}

private enum TrendMetric: String, CaseIterable {
    case entries = "Entries"
    case wins = "Wins"
    case streak = "Streak"
    case confidence = "Confidence"
    case mood = "Mood"
    case energy = "Energy"
    case stress = "Stress"
}

struct DashboardView: View {
    @Query private var notes: [QuickNote]
    @Query private var reflections: [Reflection]
    @Query private var studyItems: [StudyItem]
    @Query private var dailyLogs: [DailyLog]

    @State private var range: DashboardRange = .week
    @State private var metric: TrendMetric = .entries

    private var streak: Int {
        DashboardStats.currentStreak(reflections: reflections)
    }

    private var entriesInRange: Int {
        let calendar = Calendar.current
        guard let cutoff = calendar.date(byAdding: .day, value: -range.days, to: Date()) else { return 0 }
        let noteCount = notes.filter { $0.dateCreated >= cutoff }.count
        let reflectionCount = reflections.filter { $0.date >= cutoff }.count
        return noteCount + reflectionCount
    }

    private var openStudyItems: Int {
        studyItems.filter { !$0.isReviewed }.count
    }

    private var winCountInRange: Int {
        let calendar = Calendar.current
        guard let cutoff = calendar.date(byAdding: .day, value: -range.days, to: Date()) else { return 0 }
        return notes.filter { ($0.tag == .win || $0.highlightType == .win) && $0.dateCreated >= cutoff }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Range", selection: $range) {
                        ForEach(DashboardRange.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Current Streak", value: "\(streak)", subtitle: streak == 1 ? "day" : "days", color: .purple)
                        StatCard(title: "Entries", value: "\(entriesInRange)", subtitle: "notes & reflections", color: .blue)
                        StatCard(title: "Open Study Items", value: "\(openStudyItems)", subtitle: "to review", color: .orange)
                        StatCard(title: "Wins", value: "\(winCountInRange)", subtitle: "highlighted", color: .green)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Picker("Metric", selection: $metric) {
                            ForEach(TrendMetric.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .padding(.horizontal)

                        trendChart
                            .frame(height: 180)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
        }
    }

    @ViewBuilder
    private var trendChart: some View {
        switch metric {
        case .entries:
            let data = DashboardStats.entryCountsByDay(notes: notes, lastDays: range.days)
            if data.allSatisfy({ $0.count == 0 }) {
                emptyChartState
            } else {
                Chart(data, id: \.day) { entry in
                    BarMark(x: .value("Day", entry.day, unit: .day), y: .value("Notes", entry.count))
                        .foregroundStyle(Color.accentColor)
                }
            }
        case .wins:
            let data = DashboardStats.winCountsByDay(notes: notes, lastDays: range.days)
            if data.allSatisfy({ $0.count == 0 }) {
                emptyChartState
            } else {
                Chart(data, id: \.day) { entry in
                    BarMark(x: .value("Day", entry.day, unit: .day), y: .value("Wins", entry.count))
                        .foregroundStyle(Color.green)
                }
            }
        case .streak:
            let data = DashboardStats.streakSeriesByDay(reflections: reflections, lastDays: range.days)
            Chart(data, id: \.day) { entry in
                BarMark(x: .value("Day", entry.day, unit: .day), y: .value("Completed", entry.completed ? 1 : 0))
                    .foregroundStyle(Color.purple)
            }
        case .confidence, .mood, .energy, .stress:
            let keyPath = moodKeyPath(for: metric)
            let data = DashboardStats.moodTrend(logs: dailyLogs, keyPath: keyPath, lastDays: range.days)
            if data.isEmpty {
                emptyChartState
            } else {
                Chart(data, id: \.day) { entry in
                    LineMark(x: .value("Day", entry.day, unit: .day), y: .value(metric.rawValue, entry.value))
                        .foregroundStyle(Color.blue)
                    PointMark(x: .value("Day", entry.day, unit: .day), y: .value(metric.rawValue, entry.value))
                        .foregroundStyle(Color.blue)
                }
                .chartYScale(domain: 1...5)
            }
        }
    }

    private var emptyChartState: some View {
        ContentUnavailableView("No Data Yet", systemImage: "chart.bar", description: Text("Log a few days to see this trend."))
    }

    private func moodKeyPath(for metric: TrendMetric) -> KeyPath<DailyLog, Int?> {
        switch metric {
        case .confidence: return \.confidenceValue
        case .mood: return \.moodValue
        case .energy: return \.energyValue
        case .stress: return \.stressValue
        default: return \.moodValue
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(color)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DashboardView()
        .modelContainer(SampleData.container)
}
