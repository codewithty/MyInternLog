import Foundation

// Builds copy/paste-ready prompt text for an external AI tool. MyInternLog
// never calls an AI API itself — the user copies this, pastes it into their
// own ChatGPT (or similar), and pastes the result back in.
enum AIPromptBuilder {

    static func buildPrompt(
        type: CareerOutputType,
        targetRole: String,
        resumeStyle: ResumeBulletStyle? = nil,
        notes: [QuickNote],
        reflections: [Reflection],
        milestones: [Milestone] = [],
        profile: InternshipProfile,
        useGenericWording: Bool
    ) -> String {
        // Deliberately not "technical" or "internship": the app is used for co-ops,
        // research roles, and jobs too, and the wrong framing skews the AI's wording.
        let genericContext = "a work experience such as an internship or co-op"
        let context: String
        if useGenericWording {
            context = genericContext
        } else {
            let parts = [profile.title, profile.organization].filter { !$0.isEmpty }
            context = parts.isEmpty ? genericContext : parts.joined(separator: " at ")
        }

        var lines: [String] = []
        lines.append("I'm writing a \(type.label.lowercased()) based on my work notes. Please write it in clear, professional language.")
        lines.append("Context: \(context)")
        if !targetRole.isEmpty {
            lines.append("Target role/context: \(targetRole)")
        }
        if let resumeStyle {
            lines.append("Bullet style: \(resumeStyle.label)")
        }
        lines.append("")
        lines.append("Here are my raw notes and reflections:")

        // The end-of-internship summary and CUNY prep are meant to use
        // everything available; other prompt types stay short so the
        // copy/paste prompt is manageable.
        let usesFullHistory = type == .endOfInternshipSummary || type == .cunyPresentationPrep
        let noteLimit = usesFullHistory ? notes.count : 15
        let reflectionLimit = usesFullHistory ? reflections.count : 5

        for note in notes.prefix(noteLimit) {
            let body = note.body.isEmpty ? "" : " — \(note.body)"
            lines.append("- \(note.title)\(body)")
        }
        for reflection in reflections.prefix(reflectionLimit) {
            for answer in reflection.answers where !answer.answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                lines.append("- \(answer.promptText): \(answer.answerText)")
            }
        }

        if !milestones.isEmpty {
            lines.append("")
            lines.append("Key dates/milestones:")
            for milestone in milestones {
                lines.append("- \(milestone.title) (\(milestone.type.label)): \(milestone.date.formatted(date: .abbreviated, time: .omitted))")
            }
        }

        if notes.isEmpty && reflections.isEmpty {
            lines.append("(No notes yet — write a short placeholder I can fill in later.)")
        }

        lines.append("")
        lines.append("Before you send this, please review it and remove anything confidential, classified, or otherwise sensitive.")
        return lines.joined(separator: "\n")
    }
}
