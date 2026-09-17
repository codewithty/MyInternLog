import SwiftUI

struct DayDetailView: View {
    let date: Date
    let dailyLog: DailyLog?

    var body: some View {
        NavigationStack {
            List {
                let notes = dailyLog?.quickNotes ?? []
                let reflections = dailyLog?.reflections ?? []
                let attachments = dailyLog?.attachments ?? []

                if notes.isEmpty && reflections.isEmpty && attachments.isEmpty {
                    ContentUnavailableView("Nothing Logged", systemImage: "calendar.badge.exclamationmark")
                }

                if !notes.isEmpty {
                    Section("Quick Notes") {
                        ForEach(notes) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title).font(.headline)
                                if !note.body.isEmpty {
                                    Text(note.body)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                }
                            }
                        }
                    }
                }

                if !reflections.isEmpty {
                    Section("Reflections") {
                        ForEach(reflections) { reflection in
                            NavigationLink(destination: ReflectionDetailView(reflection: reflection)) {
                                HStack {
                                    Text(reflection.templateName + " Reflection")
                                    Spacer()
                                    if reflection.isComplete {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                        }
                    }
                }

                if !attachments.isEmpty {
                    Section("Attachments") {
                        Label("\(attachments.count) attachment\(attachments.count == 1 ? "" : "s")", systemImage: "paperclip")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    DayDetailView(date: Date(), dailyLog: nil)
}
