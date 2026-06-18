import SwiftUI
import SwiftData

struct ReflectionListView: View {
    @Query(sort: \Reflection.date, order: .reverse) private var reflections: [Reflection]
    @State private var showingStartReflection = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(reflections) { reflection in
                    NavigationLink(destination: ReflectionDetailView(reflection: reflection)) {
                        ReflectionRow(reflection: reflection)
                    }
                }
            }
            .overlay {
                if reflections.isEmpty {
                    ContentUnavailableView("No Reflections Yet", systemImage: "text.book.closed")
                }
            }
            .navigationTitle("Reflections")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingStartReflection = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingStartReflection) {
                StartReflectionView()
            }
        }
    }
}

struct ReflectionRow: View {
    let reflection: Reflection

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(reflection.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Spacer()
                Text(reflection.isComplete ? "Complete" : "Draft")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(reflection.isComplete ? Color.green.opacity(0.15) : Color.secondary.opacity(0.15))
                    .foregroundStyle(reflection.isComplete ? Color.green : Color.secondary)
                    .clipShape(Capsule())
            }
            Text(reflection.templateName + " Reflection")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ReflectionListView()
        .modelContainer(for: [Reflection.self, ReflectionAnswer.self], inMemory: true)
}
