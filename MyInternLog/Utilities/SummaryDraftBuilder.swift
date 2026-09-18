import Foundation

// Turns today's raw notes into suggested reflection answers using simple,
// transparent rules — never an AI call. Suggestions are always editable and
// only fill prompts that don't already have an answer.
enum SummaryDraftBuilder {

    static func suggestions(for prompts: [String], notes: [QuickNote], openStudyItems: [StudyItem]) -> [String: String] {
        var didTitles: [String] = []
        var learnedTitles: [String] = []
        var studyLaterTitles: [String] = []
        var blockerTitles: [String] = []
        var winTitles: [String] = []
        var skillNames: Set<String> = []

        for note in notes {
            didTitles.append(note.title)
            if note.tag == .idea || note.highlightType == .important {
                learnedTitles.append(note.title)
            }
            if note.tag == .studyLater || note.highlightType == .studyLater {
                studyLaterTitles.append(note.title)
            }
            if note.tag == .blocker {
                blockerTitles.append(note.title)
            }
            if note.tag == .win || note.highlightType == .win {
                winTitles.append(note.title)
            }
            for item in note.knowledgeItems {
                skillNames.insert(item.name)
            }
        }
        for item in openStudyItems {
            studyLaterTitles.append(item.title)
        }

        var result: [String: String] = [:]
        for prompt in prompts {
            let lower = prompt.lowercased()
            var suggestion: String?
            if lower.contains("what did i do") || lower.contains("work completed") {
                suggestion = bulletList(didTitles)
            } else if lower.contains("learn") {
                suggestion = bulletList(learnedTitles)
            } else if lower.contains("review later") || lower.contains("study") {
                suggestion = bulletList(studyLaterTitles)
            } else if lower.contains("problem") || lower.contains("blocker") || lower.contains("challenge") {
                suggestion = bulletList(blockerTitles)
            } else if lower.contains("win") || lower.contains("accomplishment") {
                suggestion = bulletList(winTitles)
            } else if lower.contains("skill") || lower.contains("tool") || lower.contains("concept") {
                suggestion = bulletList(Array(skillNames))
            }
            if let suggestion, !suggestion.isEmpty {
                result[prompt] = suggestion
            }
        }
        return result
    }

    private static func bulletList(_ items: [String]) -> String {
        items.map { "- \($0)" }.joined(separator: "\n")
    }
}
