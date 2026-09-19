import SwiftUI
import SwiftData

struct EndOfInternshipView: View {
    @Query private var notes: [QuickNote]
    @Query private var reflections: [Reflection]
    @Query private var studyItems: [StudyItem]
    @Query private var careerOutputs: [CareerOutput]
    @Query private var milestones: [Milestone]

    @State private var showingExport = false
    @State private var showingPDFExport = false

    private var mainThingsWorkedOn: [String] { Array(Set(notes.map(\.title))).sorted().prefix(10).map { $0 } }
    private var learned: [String] {
        notes.filter { $0.tag == .idea || $0.highlightType == .important }.map(\.title)
    }
    private var problemsOvercome: [String] {
        notes.filter { $0.tag == .blocker }.map(\.title)
    }
    private var wins: [String] {
        notes.filter { $0.tag == .win || $0.highlightType == .win }.map(\.title)
    }
    private var skillsUsed: [String] {
        Array(Set(notes.flatMap(\.knowledgeItems).map(\.name))).sorted()
    }
    private var stillToStudy: [String] {
        studyItems.filter { !$0.isReviewed }.map(\.title)
    }
    private var streak: Int { DashboardStats.currentStreak(reflections: reflections) }
    private var completedReflections: Int { reflections.filter(\.isComplete).count }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "graduationcap.fill").foregroundStyle(.purple)
                        VStack(alignment: .leading) {
                            Text("\(notes.count) notes · \(completedReflections) completed reflections").font(.subheadline.bold())
                            Text("Longest streak so far: \(streak) day\(streak == 1 ? "" : "s")").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }

                summarySection("Main Things Worked On", items: mainThingsWorkedOn, icon: "hammer.fill", color: .blue)
                summarySection("What Was Learned", items: learned, icon: "lightbulb.fill", color: .yellow)
                summarySection("Problems Overcome", items: problemsOvercome, icon: "checkmark.shield.fill", color: .red)
                summarySection("Accomplishments / Wins", items: wins, icon: "star.fill", color: .green)
                summarySection("Skills, Tools & Concepts Used", items: skillsUsed, icon: "brain.head.profile", color: .purple)
                summarySection("Still To Study", items: stillToStudy, icon: "books.vertical.fill", color: .orange)

                if !milestones.isEmpty {
                    Section("Milestones") {
                        ForEach(milestones.sorted { $0.date < $1.date }) { milestone in
                            Text(milestone.title + " — " + milestone.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                        }
                    }
                }

                Section {
                    Button {
                        showingExport = true
                    } label: {
                        Label("Generate AI-Assisted Summary", systemImage: "sparkles")
                    }
                    Button {
                        showingPDFExport = true
                    } label: {
                        Label("Export Full PDF", systemImage: "doc.richtext")
                    }
                    NavigationLink("View All Career Outputs") {
                        CareerOutputListView()
                    }
                }
            }
            .navigationTitle("Wrap-Up")
            .sheet(isPresented: $showingExport) {
                PromptExportView(initialType: .endOfInternshipSummary)
            }
            .sheet(isPresented: $showingPDFExport) {
                PDFExportView()
            }
        }
    }

    @ViewBuilder
    private func summarySection(_ title: String, items: [String], icon: String, color: Color) -> some View {
        if !items.isEmpty {
            Section(title) {
                ForEach(items.prefix(10), id: \.self) { item in
                    Label(item, systemImage: icon)
                        .foregroundStyle(color)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    EndOfInternshipView()
        .modelContainer(SampleData.container)
}
