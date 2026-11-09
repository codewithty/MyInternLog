import Foundation
import FoundationModels

// The "form" the on-device model must fill in. Guided generation forces the
// output into this shape, so every bullet has an X, a Y slot, and a Z.
@Generable
struct GeneratedXYZBullet {
    @Guide(description: "What was accomplished, starting with a strong past-tense action verb, e.g. 'Stabilized a flaky integration test'")
    var accomplishment: String

    @Guide(description: "A measurable result copied from the notes, e.g. 'passing 20 consecutive runs'. Empty string if the notes contain no number or measurable result. Never invent one.")
    var measure: String

    @Guide(description: "How it was done, starting with 'by', e.g. 'by adding a wait to the test setup'")
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
            instructions: "You write resume bullets in XYZ format: accomplished X, as measured by Y, by doing Z. Use only facts from the notes. Never invent numbers, tools, people, or results."
        )
        let response = try await session.respond(
            to: XYZBulletBuilder.prompt(notes: usable, targetRole: targetRole),
            generating: GeneratedXYZBulletList.self
        )

        let sentences = response.content.bullets
            .prefix(5)
            .map { XYZBulletBuilder.sentence(accomplishment: $0.accomplishment, measure: $0.measure, method: $0.method) }
            .filter { !$0.isEmpty }

        return sentences.map { "• \($0)" }.joined(separator: "\n")
    }
}
