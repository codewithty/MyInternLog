import SwiftUI

// A wrapping grid of toggleable chips, used for tags and skills/tools/concepts.
// Callers pass plain strings so this view stays independent of which model
// (Tag vs KnowledgeItem) backs the chip.
struct ChipFlowPicker: View {
    let allOptions: [String]
    @Binding var selected: Set<String>
    var chipColor: Color = .blue

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(allOptions, id: \.self) { option in
                let isSelected = selected.contains(option)
                Text(option)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isSelected ? chipColor.opacity(0.25) : Color.secondary.opacity(0.12))
                    .foregroundStyle(isSelected ? chipColor : Color.primary)
                    .clipShape(Capsule())
                    .onTapGesture {
                        if isSelected {
                            selected.remove(option)
                        } else {
                            selected.insert(option)
                        }
                    }
            }
        }
    }
}

// Text field + "Add" button for creating a brand-new chip inline.
struct AddChipField: View {
    let placeholder: String
    let onAdd: (String) -> Void

    @State private var text = ""

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
            Button("Add") {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                onAdd(trimmed)
                text = ""
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}
