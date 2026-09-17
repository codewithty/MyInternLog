import SwiftUI

// ProjectGroup (and similar models) store a color as a plain string so
// SwiftData doesn't need to persist Color directly. This maps that name
// back to a real SwiftUI Color.
extension Color {
    static func named(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        case "teal": return .teal
        case "red": return .red
        case "indigo": return .indigo
        case "yellow": return .yellow
        default: return .gray
        }
    }
}
