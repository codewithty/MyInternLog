import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query private var notes: [QuickNote]
    @Query private var reflections: [Reflection]
    @Query private var studyItems: [StudyItem]

    private var streak: Int {
        DashboardStats.currentStreak(reflections: reflections)
    }

    private var entriesThisWeek: Int {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return 0 }
        let noteCount = notes.filter { weekInterval.contains($0.dateCreated) }.count
        let reflectionCount = reflections.filter { weekInterval.contains($0.date) }.count
        return noteCount + reflectionCount
    }

    private var openStudyItems: Int {
        studyItems.filter { !$0.isReviewed }.count
    }

    private var winCount: Int {
        notes.filter { $0.tag == .win }.count
    }

    private var last7Days: [(day: Date, count: Int)] {
        DashboardStats.entryCountsByDay(notes: notes, lastDays: 7)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Current Streak", value: "\(streak)", subtitle: streak == 1 ? "day" : "days", color: .purple)
                        StatCard(title: "Entries This Week", value: "\(entriesThisWeek)", subtitle: "notes & reflections", color: .blue)
                        StatCard(title: "Open Study Items", value: "\(openStudyItems)", subtitle: "to review", color: .orange)
                        StatCard(title: "Wins", value: "\(winCount)", subtitle: "highlighted", color: .green)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("Entries — Last 7 Days")
                            .font(.headline)
                            .padding(.horizontal)

                        Chart(last7Days, id: \.day) { entry in
                            BarMark(
                                x: .value("Day", entry.day, unit: .day),
                                y: .value("Notes", entry.count)
                            )
                            .foregroundStyle(Color.accentColor)
                        }
                        .frame(height: 180)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
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
        .modelContainer(for: [QuickNote.self, Reflection.self, StudyItem.self], inMemory: true)
}
