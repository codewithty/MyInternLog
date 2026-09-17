import SwiftUI
import SwiftData

private enum PDFRange: String, CaseIterable {
    case today = "Today"
    case thisWeek = "This Week"
    case all = "All Internship"
}

private struct IdentifiableURL: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct PDFExportView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DailyLog.date) private var logs: [DailyLog]

    @State private var range: PDFRange = .thisWeek
    @State private var shareURL: IdentifiableURL?
    @State private var isGenerating = false

    private var profile: InternshipProfile { InternshipProfile.current(in: context) }

    private var filteredLogs: [DailyLog] {
        let calendar = Calendar.current
        switch range {
        case .today:
            return logs.filter { calendar.isDateInToday($0.date) }
        case .thisWeek:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
            return logs.filter { interval.contains($0.date) }
        case .all:
            return logs
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Report Range") {
                    Picker("Range", selection: $range) {
                        ForEach(PDFRange.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Text("\(filteredLogs.count) day\(filteredLogs.count == 1 ? "" : "s") of entries will be included. Review the PDF for sensitive details before sharing.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        generateAndShare()
                    } label: {
                        if isGenerating {
                            ProgressView()
                        } else {
                            Label("Generate PDF", systemImage: "doc.richtext")
                        }
                    }
                    .disabled(filteredLogs.isEmpty || isGenerating)
                }
            }
            .navigationTitle("Export PDF")
            .sheet(item: $shareURL) { wrapper in
                ShareSheet(items: [wrapper.url])
            }
        }
    }

    private func generateAndShare() {
        isGenerating = true
        let body = buildBodyText()
        let title = profile.title.isEmpty ? "Internship Journal" : profile.title
        let subtitle = range.rawValue + (profile.organization.isEmpty ? "" : " · \(profile.organization)")

        let data = PDFExportService.generateJournalPDF(title: title, subtitle: subtitle, generatedAt: Date(), body: body)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("MyInternLog-\(range.rawValue).pdf")
        if (try? data.write(to: url)) != nil {
            shareURL = IdentifiableURL(url: url)
        }
        isGenerating = false
    }

    private func buildBodyText() -> String {
        var lines: [String] = []
        for log in filteredLogs {
            lines.append(log.date.formatted(date: .complete, time: .omitted))
            lines.append(String(repeating: "-", count: 40))
            for note in log.quickNotes {
                lines.append("Note: \(note.title)")
                if !note.body.isEmpty { lines.append(note.body) }
            }
            for reflection in log.reflections {
                lines.append("\(reflection.templateName) Reflection\(reflection.isComplete ? " (complete)" : " (draft)"):")
                for answer in reflection.answers.sorted(by: { $0.displayOrder < $1.displayOrder }) where !answer.answerText.isEmpty {
                    lines.append("\(answer.promptText): \(answer.answerText)")
                }
            }
            lines.append("")
        }
        if lines.isEmpty {
            lines.append("No entries in this range yet.")
        }
        return lines.joined(separator: "\n")
    }
}

#Preview {
    PDFExportView()
        .modelContainer(for: [DailyLog.self, QuickNote.self, Reflection.self, InternshipProfile.self], inMemory: true)
}
