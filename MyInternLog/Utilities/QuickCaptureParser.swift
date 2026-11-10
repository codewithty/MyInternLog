import Foundation

// Quick capture is one text box: the first line becomes the note's title and
// everything after it becomes the body, like Apple Notes. Kept separate from
// the view so it can be unit tested.
enum QuickCaptureParser {

    static let maxTitleLength = 80

    static func split(_ text: String) -> (title: String, body: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "") }

        let lines = trimmed.components(separatedBy: .newlines)
        let firstLine = lines[0].trimmingCharacters(in: .whitespaces)
        let rest = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)

        // A short first line is the title as-is.
        guard firstLine.count > maxTitleLength else {
            return (firstLine, rest)
        }

        // One long line: cut the title at the last space before the limit and
        // keep the full text in the body so nothing is lost.
        let prefix = String(firstLine.prefix(maxTitleLength))
        let cut = prefix.lastIndex(of: " ").map { String(prefix[..<$0]) } ?? prefix
        let body = rest.isEmpty ? firstLine : firstLine + "\n" + rest
        return (cut + "…", body)
    }
}
