import Foundation

// Shared 1-5 scale for mood/confidence/energy/stress. Stored as plain Ints
// behind the scenes; the UI only ever shows emoji/label endpoints.
enum MoodScale {
    static let range = 1...5

    static func label(_ value: Int, low: String, high: String) -> String {
        switch value {
        case 1: return low
        case 5: return high
        default: return "\(value)"
        }
    }
}
