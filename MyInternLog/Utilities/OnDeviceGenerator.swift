import Foundation
import FoundationModels

// Runs a prompt through Apple's on-device model (Foundation Models, iOS 26).
// Nothing leaves the phone. This is the second way to fill the AI Export result
// box; the copy/paste flow stays for devices without Apple Intelligence.
enum OnDeviceGenerator {

    // Whether the on-device model can run right now, and if not, a reason the
    // user can act on.
    enum Status: Equatable {
        case available
        case unavailable(String)
    }

    static var status: Status {
        switch SystemLanguageModel.default.availability {
        case .available:
            return .available
        case .unavailable(.deviceNotEligible):
            return .unavailable("This iPhone doesn't support Apple Intelligence. Use the copy/paste option below.")
        case .unavailable(.appleIntelligenceNotEnabled):
            return .unavailable("Turn on Apple Intelligence in Settings to generate on this iPhone.")
        case .unavailable(.modelNotReady):
            return .unavailable("Apple Intelligence is still downloading. Try again in a few minutes.")
        case .unavailable:
            return .unavailable("On-device generation isn't available right now.")
        }
    }

    // Sends the prompt to the on-device model and returns its text.
    static func generate(from prompt: String) async throws -> String {
        let session = LanguageModelSession(
            instructions: "You turn a person's raw work notes into polished career writing. Use only facts from the notes. Never invent numbers, tools, or results that aren't in the notes."
        )
        let response = try await session.respond(to: prompt)
        return response.content
    }

    // Turns the framework's errors into something a user can act on.
    static func message(for error: Error) -> String {
        if let issue = error as? XYZBulletGenerator.GenerationIssue {
            return issue.errorDescription ?? "Couldn't generate bullets."
        }
        if let generationError = error as? LanguageModelSession.GenerationError {
            switch generationError {
            case .exceededContextWindowSize:
                return "Too many notes for the on-device model. Trim the prompt above, or use the copy/paste option."
            case .guardrailViolation:
                return "The on-device model declined this prompt. Try editing it, or use the copy/paste option."
            default:
                break
            }
        }
        return "Generation failed: \(error.localizedDescription)"
    }
}
