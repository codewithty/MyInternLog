import Foundation

enum ReflectionTemplate: String, CaseIterable {
    case quick = "Quick"
    case full = "Full"

    var prompts: [String] {
        switch self {
        case .quick:
            return [
                "What did I do?",
                "What did I learn?",
                "What should I review later?"
            ]
        case .full:
            return [
                "Work completed",
                "What I learned",
                "Problems faced",
                "How I solved them",
                "Questions I still have",
                "Wins / accomplishments",
                "Skills, tools, and concepts used",
                "Things to study later",
                "Next steps",
                "Freeform notes"
            ]
        }
    }
}
