import Foundation

// The non-AI half of on-device XYZ bullets: picks which notes to send, writes
// the prompt, and turns the model's X/Y/Z pieces into a sentence. Kept free of
// FoundationModels so it can be unit tested.
enum XYZBulletBuilder {

    // The on-device model's context window is about 4,096 tokens (prompt and
    // answer combined), so cap how much we send.
    static let maxNotes = 12
    static let maxBodyLength = 200

    // Tags that are never accomplishments, so they never become resume bullets.
    static let excludedTags: Set<NoteTag> = [.idea, .question, .blocker, .studyLater]

    // Keeps only finished work, removes duplicate titles, puts Resume-Worthy and
    // Win notes first, and caps the count.
    static func notesForBullets(from notes: [QuickNote]) -> [QuickNote] {
        var seenTitles = Set<String>()
        var kept: [QuickNote] = []

        for note in notes {
            if excludedTags.contains(note.tag) { continue }
            if note.highlightType == .studyLater { continue }

            let key = note.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if key.isEmpty || seenTitles.contains(key) { continue }
            seenTitles.insert(key)
            kept.append(note)
        }

        // Stable sort: highlighted notes first, otherwise keep the original order.
        let ranked = kept.enumerated().sorted { a, b in
            let rankA = priority(of: a.element), rankB = priority(of: b.element)
            return rankA == rankB ? a.offset < b.offset : rankA < rankB
        }.map(\.element)

        return Array(ranked.prefix(maxNotes))
    }

    private static func priority(of note: QuickNote) -> Int {
        if note.highlightType == .resumeWorthy { return 0 }
        if note.highlightType == .win || note.tag == .win { return 1 }
        return 2
    }

    static func prompt(notes: [QuickNote], targetRole: String) -> String {
        var lines: [String] = []
        lines.append("Write 3 to 5 resume bullets from these work notes.")
        let role = targetRole.trimmingCharacters(in: .whitespacesAndNewlines)
        if !role.isEmpty {
            lines.append("Target role: \(role). Favor work that's relevant to it.")
        }
        lines.append("Only write bullets for work that is already finished. Skip plans, future tasks, and meeting notes (anything with 'tomorrow', 'will', or 'I'll').")
        lines.append("If two notes describe the same work, combine them into one bullet.")
        lines.append("If a note is only a short title, write a short bullet. Don't add results or methods that aren't in the note.")
        lines.append("")
        lines.append("Notes:")
        for note in notes {
            let body = note.body.trimmingCharacters(in: .whitespacesAndNewlines)
            if body.isEmpty {
                lines.append("- \(note.title)")
            } else {
                lines.append("- \(note.title): \(String(body.prefix(maxBodyLength)))")
            }
        }
        return lines.joined(separator: "\n")
    }

    // "Accomplished X, as measured by Y, by doing Z". Leaves out Y when there's
    // no number, rather than inventing one.
    // sourceText is the notes the model was given. When it's provided, a result
    // or method is only kept if its words actually appear in the notes, so
    // filler like "finished the task" or a guessed method gets dropped.
    static func sentence(accomplishment: String, measure: String, method: String, sourceText: String? = nil) -> String {
        let x = clean(accomplishment)
        let y = clean(measure)
        let z = clean(method)

        // The on-device model sometimes writes the whole bullet into the
        // accomplishment field. Skip any part it already included so the
        // result and method don't appear twice.
        let xLower = x.lowercased()
        let methodHadBy = z.lowercased().hasPrefix("by ")
        let zCore = methodHadBy ? String(z.dropFirst(3)) : z

        let yIsGrounded = sourceText.map { isGrounded(y, in: $0) } ?? true
        let zIsGrounded = sourceText.map { isGrounded(zCore, in: $0) } ?? true

        var result = x
        if !y.isEmpty && yIsGrounded && !xLower.contains(y.lowercased()) {
            result += ", \(y)"
        }
        let alreadyHasMethod = xLower.contains(" by ") || xLower.contains(zCore.lowercased())
        if !zCore.isEmpty && zIsGrounded && !alreadyHasMethod {
            // "by" only reads right before an -ing verb ("by batching").
            // If the model wrote a past-tense verb ("walked"), join with "and".
            let firstWord = zCore.split(separator: " ").first.map { $0.lowercased() } ?? ""
            if methodHadBy || firstWord.hasSuffix("ing") {
                result += ", by \(lowercaseFirst(zCore))"
            } else {
                // Comma before "and" only when there are three parts.
                let joiner = result == x ? " and" : ", and"
                result += "\(joiner) \(lowercaseFirst(zCore))"
            }
        }
        return result.isEmpty ? "" : result + "."
    }

    // True if most of the text's meaningful words appear in the source notes.
    // Words are matched on their first 4 letters so "walking" matches "walked".
    static func isGrounded(_ text: String, in source: String) -> Bool {
        let sourceLower = source.lowercased()
        let words = text.lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
            .filter { $0.count >= 4 || $0.contains(where: \.isNumber) }
        guard !words.isEmpty else { return true }
        let found = words.filter { sourceLower.contains(String($0.prefix(4))) }.count
        return Double(found) / Double(words.count) >= 0.6
    }

    private static func clean(_ text: String) -> String {
        var t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        while let last = t.last, ".,;".contains(last) { t.removeLast() }
        return t
    }

    private static func lowercaseFirst(_ text: String) -> String {
        guard let first = text.first else { return text }
        // Keep acronyms like "API" or "SQL" as they are.
        let secondIsUpper = text.dropFirst().first?.isUppercase ?? false
        return secondIsUpper ? text : first.lowercased() + text.dropFirst()
    }
}
