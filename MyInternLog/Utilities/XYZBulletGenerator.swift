import Foundation
import FoundationModels

// The "form" the on-device model must fill in. Guided generation forces the
// output into this shape, so every bullet has an X, a Y slot, and a Z.
@Generable
struct GeneratedXYZBullet {
    @Guide(description: "ONLY what was accomplished, 3 to 8 words, starting with a past-tense action verb, e.g. 'Stabilized a flaky integration test'. Do NOT include the result or how it was done here.")
    var accomplishment: String

    @Guide(description: "ONLY a result with a number copied from the notes, e.g. 'passing 20 consecutive runs'. Empty string if the note has no number. Never write things like 'completed the task' or 'finished it'.")
    var measure: String

    @Guide(description: "ONLY how it was done, starting with 'by' and an -ing verb, e.g. 'by adding a wait to the test setup'. Empty string if the note doesn't say how. Never guess.")
    var method: String
}

@Generable
struct GeneratedXYZBulletList {
    @Guide(description: "3 to 5 resume bullets, one per distinct accomplishment, no duplicates")
    var bullets: [GeneratedXYZBullet]
}

enum XYZBulletGenerator {

    enum GenerationIssue: LocalizedError {
        case noUsableNotes

        var errorDescription: String? {
            "No finished work to turn into bullets yet. Questions, ideas, blockers, and study notes are skipped. Log a Win or a regular note first."
        }
    }

    // Returns the bullets as text, one per line, ready for the result box.
    static func generate(from notes: [QuickNote], targetRole: String) async throws -> String {
        let usable = XYZBulletBuilder.notesForBullets(from: notes)
        guard !usable.isEmpty else { throw GenerationIssue.noUsableNotes }

        let session = LanguageModelSession(
            instructions: "You write resume bullets in XYZ format: accomplished X, as measured by Y, by doing Z. Use only facts from the notes. Never invent numbers, tools, people, or results. Only describe finished work, never plans or future tasks."
        )
        let response = try await session.respond(
            to: XYZBulletBuilder.prompt(notes: usable, targetRole: targetRole),
            generating: GeneratedXYZBulletList.self
        )

        // Used to check that each result and method really came from the notes.
        let source = usable.map { "\($0.title) \($0.body)" }.joined(separator: "\n")

        let sentences = response.content.bullets
            .prefix(5)
            .map { XYZBulletBuilder.sentence(accomplishment: $0.accomplishment, measure: $0.measure, method: $0.method, sourceText: source) }
            .filter { !$0.isEmpty }

        return sentences.map { "• \($0)" }.joined(separator: "\n")
    }
}
