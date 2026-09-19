import Foundation

// Lets a file URL drive `.sheet(item:)`, e.g. to present the share sheet for a
// file that was just written.
struct IdentifiableURL: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}
