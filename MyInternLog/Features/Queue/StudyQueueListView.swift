import SwiftUI
import SwiftData

struct StudyQueueListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \StudyItem.dateAdded, order: .reverse) private var items: [StudyItem]
    @State private var showingAddItem = false
    @State private var editingItem: StudyItem?

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    StudyItemRow(item: item)
                        .contentShape(Rectangle())
                        .onTapGesture { editingItem = item }
                }
                .onDelete(perform: deleteItems)
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("No Study Items Yet", systemImage: "books.vertical")
                }
            }
            .navigationTitle("Study Queue")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddStudyItemView()
            }
            .sheet(item: $editingItem) { item in
                EditStudyItemView(item: item)
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            context.delete(items[index])
        }
    }
}

struct StudyItemRow: View {
    @Bindable var item: StudyItem

    var body: some View {
        HStack(spacing: 12) {
            Button {
                item.isReviewed.toggle()
            } label: {
                Image(systemName: item.isReviewed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isReviewed ? .green : .secondary)
                    .font(.title2)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .strikethrough(item.isReviewed)
                    .foregroundStyle(item.isReviewed ? .secondary : .primary)

                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StudyQueueListView()
        .modelContainer(for: StudyItem.self, inMemory: true)
}
