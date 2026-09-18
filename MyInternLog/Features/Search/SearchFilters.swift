import Foundation

enum SearchResultType: String, CaseIterable, Identifiable {
    case notes = "Notes"
    case studyItems = "Study Items"
    case reflections = "Reflections"
    case attachments = "Attachments"
    case milestones = "Milestones"
    case careerOutputs = "Career Outputs"

    var id: String { rawValue }
}

enum SearchDateFilter: String, CaseIterable, Identifiable {
    case any = "Any Time"
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"

    var id: String { rawValue }

    func contains(_ date: Date, calendar: Calendar = .current) -> Bool {
        switch self {
        case .any: return true
        case .today: return calendar.isDateInToday(date)
        case .thisWeek:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return true }
            return interval.contains(date)
        case .thisMonth:
            guard let interval = calendar.dateInterval(of: .month, for: Date()) else { return true }
            return interval.contains(date)
        }
    }
}

enum ConfidenceFilter: String, CaseIterable, Identifiable {
    case any = "Any"
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }

    func matches(_ value: Int?) -> Bool {
        guard self != .any else { return true }
        guard let value else { return false }
        switch self {
        case .any: return true
        case .low: return value <= 2
        case .medium: return value == 3
        case .high: return value >= 4
        }
    }
}

struct SearchFilters {
    var activeTypes: Set<SearchResultType> = []
    var studyLaterOnly = false
    var dateFilter: SearchDateFilter = .any
    var confidenceFilter: ConfidenceFilter = .any
    var groupName: String?
    var skillName: String?

    var isDefault: Bool {
        activeTypes.isEmpty && !studyLaterOnly && dateFilter == .any && confidenceFilter == .any && groupName == nil && skillName == nil
    }

    func includes(_ type: SearchResultType) -> Bool {
        activeTypes.isEmpty || activeTypes.contains(type)
    }
}
