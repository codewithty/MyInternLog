import SwiftUI
import SwiftData

// Chooses which database the app runs against. Demo mode uses SampleData's
// in-memory store, so it can never read, change, or delete the real one.
struct RootView: View {
    let realContainer: ModelContainer

    private let demoMode = DemoMode.shared

    var body: some View {
        let isDemo = demoMode.isOn
        ContentView()
            // A new identity on every switch, so no screen keeps a context from the other store.
            .id(isDemo)
            .modelContainer(isDemo ? SampleData.container : realContainer)
    }
}
