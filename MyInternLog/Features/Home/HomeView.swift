import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \QuickNote.dateCreated, order: .reverse) private var notes: [QuickNote]
    @Query(sort: \Reflection.date, order: .reverse) private var reflections: [Reflection]

    @State private var showingQuickCapture = false
    @State private var showingSettings = false

    private var profile: InternshipProfile {
        InternshipProfile.current(in: context)
    }

    private var recentActivity: [RecentEntry] {
        let noteEntries = notes.prefix(5).map { RecentEntry(id: $0.id, title: $0.title.isEmpty ? "Untitled Note" : $0.title, date: $0.dateCreated, kind: .note) }
        let reflectionEntries = reflections.prefix(5).map { RecentEntry(id: $0.id, title: $0.templateName + " Reflection", date: $0.date, kind: .reflection) }
        return (noteEntries + reflectionEntries)
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    Button {
                        showingQuickCapture = true
                    } label: {
                        Label("Let's Log", systemImage: "square.and.pencil")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)

                    launchpad

                    recentSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingQuickCapture) {
                AddQuickNoteView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("MyInternLog")
                .font(.largeTitle.bold())
            Text("Never forget what you accomplished.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text(Date().formatted(date: .complete, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if profile.showWeekNumber, let week = profile.weekNumber() {
                    Text("· Week \(week)")
                        .font(.caption.bold())
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .padding(.horizontal)
    }

    private var launchpad: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Explore")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                NavigationLink(destination: CalendarView()) {
                    LaunchTile(title: "Calendar", systemImage: "calendar", color: .orange)
                }
                NavigationLink(destination: DashboardView()) {
                    LaunchTile(title: "Dashboard", systemImage: "chart.bar.fill", color: .blue)
                }
                NavigationLink(destination: GalleryView()) {
                    LaunchTile(title: "Gallery", systemImage: "photo.on.rectangle", color: .pink)
                }
                NavigationLink(destination: WeeklyRecapView()) {
                    LaunchTile(title: "Weekly Recap", systemImage: "sparkles", color: .purple)
                }
                NavigationLink(destination: EntriesListView()) {
                    LaunchTile(title: "Entries", systemImage: "archivebox.fill", color: .teal)
                }
                NavigationLink(destination: CareerOutputListView()) {
                    LaunchTile(title: "Career Outputs", systemImage: "briefcase.fill", color: .indigo)
                }
                NavigationLink(destination: PDFExportView()) {
                    LaunchTile(title: "Export PDF", systemImage: "doc.richtext", color: .red)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Activity")
                .font(.headline)
                .padding(.horizontal)

            if recentActivity.isEmpty {
                ContentUnavailableView("No Entries Yet", systemImage: "tray")
            } else {
                VStack(spacing: 0) {
                    ForEach(recentActivity) { entry in
                        HStack {
                            Image(systemName: entry.kind == .note ? "note.text" : "text.book.closed")
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading) {
                                Text(entry.title).font(.subheadline)
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        Divider().padding(.leading)
                    }
                }
            }
        }
    }
}

private struct RecentEntry: Identifiable {
    enum Kind { case note, reflection }
    let id: UUID
    let title: String
    let date: Date
    let kind: Kind
}

private struct LaunchTile: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [QuickNote.self, Reflection.self, InternshipProfile.self], inMemory: true)
}
