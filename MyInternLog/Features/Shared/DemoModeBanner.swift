import SwiftUI

// Shown above the tab bar while demo mode is on, so it's obvious nothing is saved.
struct DemoModeBanner: View {
    var body: some View {
        HStack {
            Label("Demo mode: nothing here is saved", systemImage: "sparkles")
                .font(.footnote)
            Spacer()
            Button("Exit") { DemoMode.shared.isOn = false }
                .font(.footnote.bold())
        }
        .padding(.horizontal)
    }
}

#Preview {
    DemoModeBanner()
}
