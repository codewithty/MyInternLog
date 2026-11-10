import SwiftUI
import SwiftData

// Home shows four things: a capture card, this week's numbers, the resume
// bullet generator, and the last few notes. Everything else lives in one quiet
// "More" list at the bottom instead of nine same-size tiles.
struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \QuickNote.dateCreated, order: .reverse) private var notes: [QuickNote]

    @State private var showingSettings = false
    @State private var showingCapture = false
    @State private var showingBullets = false

    private var profile: InternshipProfile {
        InternshipProfile.current(in: context)
    }

    private var weekNotes: [QuickNote] { HomeStats.notesThisWeek(notes) }
    private var weekWins: Int { weekNotes.filter(HomeStats.isWin).count }
    private var streak: Int { HomeStats.captureStreak(notes) }

    private var roleLine: String {
        let parts = [profile.title, profile.organization].filter { !$0.isEmpty }
        return parts.joined(separator: " at ")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    captureCard
                    weekSection
                    bulletsCard
                    recentSection
                    moreSection
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showingSettings) { SettingsView() }
            .sheet(isPresented: $showingCapture) { AddQuickNoteView() }
            .sheet(isPresented: $showingBullets) { PromptExportView(initialType: .resumeBullet) }
        }
    }

    // MARK: - Header

    // Title is today's date. With Settings > "Show week number" on (and a start
    // date set), the title becomes the internship week and the date moves under it.
    private var weekNumber: Int? {
        profile.showWeekNumber ? profile.weekNumber() : nil
    }

    private var dateText: String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let weekNumber {
                Text("Week \(weekNumber)")
                    .font(.largeTitle.bold())
                Text(dateText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text(dateText)
                    .font(.largeTitle.bold())
            }
            if !roleLine.isEmpty {
                Text(roleLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Capture

    private var captureCard: some View {
        Button {
            showingCapture = true
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("What did you just do?")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "plus")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.accentColor, in: Circle())
                }
                HStack(spacing: 8) {
                    ForEach([NoteTag.win, .blocker, .question, .idea], id: \.self) { kind in
                        Text(kind.label)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.secondarySystemFill), in: Capsule())
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Log a new note")
    }

    // MARK: - This week

    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This week")
                .font(.title3.bold())
            HStack(spacing: 10) {
                StatTile(value: weekNotes.count, label: weekNotes.count == 1 ? "note" : "notes")
                StatTile(value: weekWins, label: weekWins == 1 ? "win" : "wins")
                StatTile(value: streak, label: "day streak")
            }
        }
    }

    // MARK: - Resume bullets

    private var bulletsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Private, on this iPhone", systemImage: "sparkles")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.61, green: 0.77, blue: 1.0))
            VStack(alignment: .leading, spacing: 4) {
                Text("Turn your wins into resume bullets")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(bulletsSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color(white: 0.78))
            }
            Button {
                showingBullets = true
            } label: {
                Text("Generate bullets")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 20)
                    .frame(height: 44)
                    .background(.white, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.07, green: 0.07, blue: 0.08), in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.08)))
    }

    private var bulletsSubtitle: String {
        switch weekWins {
        case 0: return "Log a win and it can become an XYZ bullet."
        case 1: return "1 win this week is ready to become an XYZ bullet."
        default: return "\(weekWins) wins this week are ready to become XYZ bullets."
        }
    }

    // MARK: - Recent

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recent")
                    .font(.title3.bold())
                Spacer()
                NavigationLink("See all") { EntriesListView() }
                    .font(.subheadline)
            }
            if notes.isEmpty {
                Text("Nothing logged yet. Tap the card above to start.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(notes.prefix(3).enumerated()), id: \.element.id) { index, note in
                        NavigationLink {
                            QuickNoteDetailView(note: note)
                        } label: {
                            RecentRow(note: note)
                        }
                        .buttonStyle(.plain)
                        if index < min(notes.count, 3) - 1 {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    // MARK: - More

    private var moreSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("More")
                .font(.title3.bold())
            VStack(spacing: 0) {
                MoreRow(title: "Calendar", systemImage: "calendar") { CalendarView() }
                Divider().padding(.leading, 52)
                MoreRow(title: "Dashboard", systemImage: "chart.bar") { DashboardView() }
                Divider().padding(.leading, 52)
                MoreRow(title: "Weekly Recap", systemImage: "sparkles") { WeeklyRecapView() }
                Divider().padding(.leading, 52)
                MoreRow(title: "Gallery", systemImage: "photo.on.rectangle") { GalleryView() }
                Divider().padding(.leading, 52)
                MoreRow(title: "Entries", systemImage: "archivebox") { EntriesListView() }
                Divider().padding(.leading, 52)
                MoreRow(title: "Career Outputs", systemImage: "briefcase") { CareerOutputListView() }
                Divider().padding(.leading, 52)
                MoreRow(title: "Export PDF", systemImage: "doc.richtext") { PDFExportView() }
                Divider().padding(.leading, 52)
                MoreRow(title: "Wrap-Up", systemImage: "graduationcap") { EndOfInternshipView() }
                Divider().padding(.leading, 52)
                MoreRow(title: "Project Groups", systemImage: "folder") { ProjectGroupsListView() }
            }
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
        }
    }
}

private struct StatTile: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.title.bold())
                .monospacedDigit()
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct RecentRow: View {
    let note: QuickNote

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(note.title.isEmpty ? "Untitled Note" : note.title)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                Text(note.dateCreated.formatted(.relative(presentation: .named)))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if note.tag != .general {
                Text(note.tag.label)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(note.tag == .win ? Color.accentColor.opacity(0.12) : Color(.secondarySystemFill), in: Capsule())
                    .foregroundStyle(note.tag == .win ? Color.accentColor : Color.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

private struct MoreRow<Destination: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .modelContainer(SampleData.container)
}
