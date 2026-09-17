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
                    Text("MyInternLog helps interns capture what they worked on, what they learned, and what they accomplished — then turns those notes into recaps, study material, and career-ready summaries.")
                }

                Section("Your data") {
                    Text("Everything you record stays on this device. There is no account, no login, and no backend server in this version.")
                }

                Section("About this project") {
                    Text("MyInternLog is a student-built educational project, created for use during a college internship.")
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
