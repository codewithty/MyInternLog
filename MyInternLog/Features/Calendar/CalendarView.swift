import SwiftUI
import SwiftData

private struct IdentifiableDate: Identifiable {
    let date: Date
    var id: TimeInterval { date.timeIntervalSinceReferenceDate }
}

struct CalendarView: View {
    @Query private var dailyLogs: [DailyLog]
    @Query(sort: \Milestone.date) private var milestones: [Milestone]

    @State private var displayedMonth = Calendar.current.startOfDay(for: Date())
    @State private var selectedDay: IdentifiableDate?
    @State private var showingAddMilestone = false

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar.current

    private var days: [Date?] {
        DateHelpers.monthGrid(for: displayedMonth, calendar: calendar)
    }

    private var milestonesThisMonth: [Milestone] {
        milestones.filter { calendar.isDate($0.date, equalTo: displayedMonth, toGranularity: .month) }
    }

    private func dailyLog(for day: Date) -> DailyLog? {
        dailyLogs.first { calendar.isDate($0.date, inSameDayAs: day) }
    }

    private func hasCompletedReflection(_ day: Date) -> Bool {
        dailyLog(for: day)?.reflections.contains { $0.isComplete } ?? false
    }

    private func hasNotesOnly(_ day: Date) -> Bool {
        guard let log = dailyLog(for: day) else { return false }
        return !log.quickNotes.isEmpty && !hasCompletedReflection(day)
    }

    private func hasMilestone(_ day: Date) -> Bool {
        milestones.contains { calendar.isDate($0.date, inSameDayAs: day) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                monthHeader
                weekdayHeader
                dayGrid

                List {
                    if milestonesThisMonth.isEmpty {
                        ContentUnavailableView("No Milestones This Month", systemImage: "flag")
                            .listRowSeparator(.hidden)
                    } else {
                        Section("Milestones This Month") {
                            ForEach(milestonesThisMonth) { milestone in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(milestone.title).font(.headline)
                                    Text(milestone.date.formatted(date: .abbreviated, time: .omitted) + " · " + milestone.type.label)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddMilestone = true
                    } label: {
                        Image(systemName: "flag.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMilestone) {
                AddMilestoneView(defaultDate: displayedMonth)
            }
            .sheet(item: $selectedDay) { wrapper in
                DayDetailView(date: wrapper.date, dailyLog: dailyLog(for: wrapper.date))
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                if let previous = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
                    displayedMonth = previous
                }
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            VStack(spacing: 2) {
                Text(DateHelpers.monthTitle(for: displayedMonth))
                    .font(.headline)
                Button("Today") {
                    displayedMonth = calendar.startOfDay(for: Date())
                }
                .font(.caption)
            }

            Spacer()

            Button {
                if let next = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
                    displayedMonth = next
                }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(calendar.veryShortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }

    private var dayGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                if let day {
                    DayCell(
                        day: day,
                        isToday: calendar.isDateInToday(day),
                        hasCompletedReflection: hasCompletedReflection(day),
                        hasNotesOnly: hasNotesOnly(day),
                        hasMilestone: hasMilestone(day)
                    )
                    .onTapGesture { selectedDay = IdentifiableDate(date: day) }
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct DayCell: View {
    let day: Date
    let isToday: Bool
    let hasCompletedReflection: Bool
    let hasNotesOnly: Bool
    let hasMilestone: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: day))")
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .frame(width: 28, height: 28)
                .background(isToday ? Color.accentColor.opacity(0.2) : Color.clear)
                .clipShape(Circle())

            HStack(spacing: 3) {
                if hasCompletedReflection {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.green)
                } else if hasNotesOnly {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 5, height: 5)
                }
                if hasMilestone {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.orange)
                }
            }
            .frame(height: 8)
        }
        .frame(height: 44)
        .contentShape(Rectangle())
    }
}

#Preview {
    CalendarView()
        .modelContainer(SampleData.container)
}
