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
    @Query private var careerOutputs: [CareerOutput]
    @Query private var allStudyItems: [StudyItem]

    @State private var range: PDFRange = .thisWeek
    @State private var template: PDFTemplate = .simpleJournal
    @State private var includeRawNotes = true
    @State private var includePhotoCaptions = true
    @State private var includeFileAttachments = true
    @State private var includeStudyItems = true
    @State private var includeMoodStats = true
    @State private var includeAISummaries = true
    @State private var includeResumeBullets = false
    @State private var useGenericWording = true
    @State private var previewText = ""
    @State private var showingPreview = false
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

                Section("Template") {
                    Picker("Template", selection: $template) {
                        ForEach(PDFTemplate.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("Include") {
                    Toggle("Raw notes", isOn: $includeRawNotes)
                    Toggle("Photo captions", isOn: $includePhotoCaptions)
                    Toggle("File attachments", isOn: $includeFileAttachments)
                    Toggle("Study items", isOn: $includeStudyItems)
                    Toggle("Mood/confidence stats", isOn: $includeMoodStats)
                    Toggle("AI-assisted summaries", isOn: $includeAISummaries)
                    Toggle("Resume bullets", isOn: $includeResumeBullets)
                }

                Section {
                    Toggle("Use generic wording", isOn: $useGenericWording)
                } footer: {
                    Text("Review the preview for sensitive, confidential, or classified details before sharing this PDF.")
                        .foregroundStyle(.orange)
                }

                Section {
                    Button("Preview") {
                        previewText = buildBodyText()
                        showingPreview = true
                    }
                    .disabled(filteredLogs.isEmpty)
                }
            }
            .navigationTitle("Export PDF")
            .sheet(isPresented: $showingPreview) {
                PDFPreviewView(text: $previewText, isGenerating: isGenerating, onExport: generateAndShare)
            }
            .sheet(item: $shareURL) { wrapper in
                ShareSheet(items: [wrapper.url])
            }
        }
    }

    private func generateAndShare() {
        isGenerating = true
        let title = useGenericWording ? "Internship" : (profile.title.isEmpty ? "Internship Journal" : profile.title)
        let organization = useGenericWording ? "" : profile.organization
        let cover = PDFCoverInfo(
            reportTitle: range.rawValue + " Report",
            internshipTitle: title,
            organization: organization,
            dateRangeDescription: dateRangeDescription(),
            generatedAt: Date()
        )
        let data = PDFExportService.generateJournalPDF(template: template, cover: cover, body: previewText)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("MyInternLog-\(range.rawValue).pdf")
        if (try? data.write(to: url)) != nil {
            shareURL = IdentifiableURL(url: url)
        }
        isGenerating = false
        showingPreview = false
    }

    private func dateRangeDescription() -> String {
        guard let first = filteredLogs.map(\.date).min(), let last = filteredLogs.map(\.date).max() else {
            return range.rawValue
        }
        return first.formatted(date: .abbreviated, time: .omitted) + " – " + last.formatted(date: .abbreviated, time: .omitted)
    }

    private func buildBodyText() -> String {
        var lines: [String] = []
        for log in filteredLogs {
            lines.append(log.date.formatted(date: .complete, time: .omitted))
            lines.append(String(repeating: "-", count: 40))

            if includeMoodStats, log.moodValue != nil || log.confidenceValue != nil || log.energyValue != nil || log.stressValue != nil {
                var stats: [String] = []
                if let v = log.moodValue { stats.append("Mood \(v)/5") }
                if let v = log.confidenceValue { stats.append("Confidence \(v)/5") }
                if let v = log.energyValue { stats.append("Energy \(v)/5") }
                if let v = log.stressValue { stats.append("Stress \(v)/5") }
                lines.append(stats.joined(separator: " · "))
            }
            if !log.selfSummary.isEmpty {
                lines.append("Summary: " + log.selfSummary)
            }

            if includeRawNotes {
                for note in log.quickNotes {
                    lines.append("Note: \(note.title)")
                    if !note.body.isEmpty { lines.append(note.body) }
                }
            }
            for reflection in log.reflections {
                lines.append("\(reflection.templateName) Reflection\(reflection.isComplete ? " (complete)" : " (draft)"):")
                for answer in reflection.answers.sorted(by: { $0.displayOrder < $1.displayOrder }) where !answer.answerText.isEmpty {
                    lines.append("\(answer.promptText): \(answer.answerText)")
                }
            }
            if includePhotoCaptions {
                for attachment in log.attachments where attachment.fileType.hasPrefix("image") {
                    lines.append("Photo: " + (attachment.caption.isEmpty ? attachment.fileName : attachment.caption))
                }
            }
            if includeFileAttachments {
                for attachment in log.attachments where !attachment.fileType.hasPrefix("image") {
                    lines.append("File: " + attachment.fileName)
                }
            }
            lines.append("")
        }

        if includeStudyItems, let first = filteredLogs.map(\.date).min(), let last = filteredLogs.map(\.date).max() {
            let items = allStudyItems.filter { $0.dateAdded >= first && $0.dateAdded <= last }
            if !items.isEmpty {
                lines.append("Study Items")
                lines.append(String(repeating: "-", count: 40))
                for item in items {
                    lines.append((item.isReviewed ? "[x] " : "[ ] ") + item.title)
                }
                lines.append("")
            }
        }

        if includeAISummaries {
            let relevant = careerOutputs.filter { $0.outputType == .dailySummary || $0.outputType == .weeklyRecap }
            if !relevant.isEmpty {
                lines.append("AI-Assisted Summaries")
                lines.append(String(repeating: "-", count: 40))
                for output in relevant {
                    lines.append(output.text)
                    lines.append("")
                }
            }
        }

        if includeResumeBullets {
            let bullets = careerOutputs.filter { $0.outputType == .resumeBullet }
            if !bullets.isEmpty {
                lines.append("Resume Bullets")
                lines.append(String(repeating: "-", count: 40))
                for bullet in bullets {
                    lines.append("• " + bullet.text)
                }
                lines.append("")
            }
        }

        if lines.isEmpty {
            lines.append("No entries in this range yet.")
        }
        return lines.joined(separator: "\n")
    }
}

private struct PDFPreviewView: View {
    @Binding var text: String
    let isGenerating: Bool
    let onExport: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .padding()
                .navigationTitle("Preview & Sanitize")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            onExport()
                        } label: {
                            if isGenerating {
                                ProgressView()
                            } else {
                                Text("Export")
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    PDFExportView()
        .modelContainer(for: [DailyLog.self, QuickNote.self, Reflection.self, InternshipProfile.self, CareerOutput.self], inMemory: true)
}
