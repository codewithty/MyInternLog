import Observation

// Whether the app is showing sample data instead of the real database.
// Deliberately not saved: every launch starts in the real app, so nobody can
// forget they're in demo mode and lose something they typed there.
// A shared instance (like NotificationRouter.shared) keeps view previews simple.
@MainActor
@Observable
final class DemoMode {
    static let shared = DemoMode()

    var isOn = false
}
