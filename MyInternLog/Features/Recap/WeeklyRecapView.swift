import SwiftUI
import SwiftData

struct WeeklyRecapView: View {
    @Environment(\.modelContext) private var context
    @Query private var allNotes: [QuickNote]
    @Query private var allStudyItems: [StudyItem]
    @Query private var allAttachments: [AttachmentItem]

    @State private var referenceDate = Date()

    private var weekInterval: DateInterval {
        Calendar.current.dateInterval(of: .weekOfYear, for: referenceDate)
            ?? DateInterval(start: referenceDate, duration: 604_800)
    }

    private var stats: WeeklyRecapStats {
        WeeklyRecapBuilder.build(notes: allNotes, studyItems: allStudyItems, attachments: allAttachments, weekInterval: weekInterval)
    }

    private var recap: WeeklyRecap {
        WeeklyRecap.findOrCreate(weekOf: referenceDate, in: context)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    weekHeader

                    if stats.entryCount == 0 {
                        ContentUnavailableView("No Notes This Week", systemImage: "calendar")
                            .padding(.top, 40)
                    } else {
                        StatRow(icon: "note.text", color: .blue, title: "\(stats.entryCount) entr\(stats.entryCount == 1 ? "y" : "ies") this week")

                        if let win = stats.biggestWin {
                            StatRow(icon: "star.fill", color: .green, title: "Biggest win", detail: win.title)
                        }

                        if !stats.topSkills.isEmpty {
                            StatRow(icon: "brain.head.profile", color: .purple, title: "Top skills/tools/concepts", detail: stats.topSkills.joined(separator: ", "))
                        }

                        if let theme = stats.commonTheme {
                            StatRow(icon: "tag.fill", color: .blue, title: "Common theme", detail: theme)
                        }

                        if !stats.blockers.isEmpty {
                            StatRow(icon: "exclamationmark.triangle.fill", color: .red, title: "Challenges / blockers", detail: stats.blockers.map(\.title).joined(separator: ", "))
                        }

                        if !stats.studyItemsAdded.isEmpty {
                            StatRow(icon: "books.vertical.fill", color: .orange, title: "Study items added", detail: stats.studyItemsAdded.map(\.title).joined(separator: ", "))
                        }

                        if !stats.photos.isEmpty {
                            photoStrip
                        }
                    }

                    recapEditor
                }
                .padding()
            }
            .navigationTitle("Weekly Recap")
        }
    }

    private var weekHeader: some View {
        HStack {
            Button {
                if let previous = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: referenceDate) {
                    referenceDate = previous
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            VStack {
                Text(weekInterval.start.formatted(date: .abbreviated, time: .omitted) + " – " + weekInterval.end.addingTimeInterval(-1).formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Text(recap.isComplete ? "Complete" : "Draft")
                    .font(.caption)
                    .foregroundStyle(recap.isComplete ? .green : .secondary)
            }
            Spacer()
            Button {
                if let next = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: referenceDate) {
                    referenceDate = next
                }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    private var photoStrip: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Photos from this week", systemImage: "photo.on.rectangle")
                .font(.subheadline.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(stats.photos) { attachment in
                        if let image = AttachmentStorage.load(fileName: attachment.localPath) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
    }

    private var recapEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            Text("Your Recap").font(.headline)

            TextField("Self summary", text: Binding(
                get: { recap.selfSummary },
                set: { recap.selfSummary = $0 }
            ), axis: .vertical)
            .lineLimit(3...)
            .textFieldStyle(.roundedBorder)

            TextField("Next week focus", text: Binding(
                get: { recap.nextWeekFocus },
                set: { recap.nextWeekFocus = $0 }
            ), axis: .vertical)
            .lineLimit(2...)
            .textFieldStyle(.roundedBorder)

            Toggle("Mark week complete", isOn: Binding(
                get: { recap.isComplete },
                set: { recap.isComplete = $0 }
            ))
        }
    }
}

private struct StatRow: View {
    let icon: String
    let color: Color
    let title: String
    var detail: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                if let detail {
                    Text(detail).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    WeeklyRecapView()
        .modelContainer(SampleData.container)
}
