import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.largeTitle)
                            .foregroundStyle(.purple)
                        Text("MyInternLog")
                            .font(.title2.bold())
                        Text("Never forget what you accomplished.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .listRowBackground(Color.clear)
                }

                Section("What it's for") {
                    Text("MyInternLog helps you capture what you worked on, what you learned, and what you accomplished during an internship, co-op, research role, or job — then turns those notes into recaps, study material, and career-ready summaries.")
                }

                Section("Your data") {
                    Text(PrivacyNotice.storage)
                    Text(PrivacyNotice.caution)
                    Text(PrivacyNotice.aiExport)
                }

                Section("About this project") {
                    Text("MyInternLog is a student-built educational project. It started as a way to log a college internship.")
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AboutView()
}
