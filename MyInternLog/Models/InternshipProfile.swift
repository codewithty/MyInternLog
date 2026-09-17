import Foundation
import SwiftData

// A single record holds the user's internship setup. There is only ever
// one InternshipProfile; `current(in:)` fetches it or creates an empty one.
@Model
final class InternshipProfile {
    var id: UUID
    var title: String
    var organization: String
    var location: String
    var startDate: Date?
    var endDate: Date?
    var mentorName: String
    var schoolProgram: String
    var presentationDate: Date?
    var notes: String
    var useGenericWordingByDefault: Bool
    var showWeekNumber: Bool

    init() {
        self.id = UUID()
        self.title = ""
        self.organization = ""
        self.location = ""
        self.startDate = nil
        self.endDate = nil
        self.mentorName = ""
        self.schoolProgram = ""
        self.presentationDate = nil
        self.notes = ""
        self.useGenericWordingByDefault = true
        self.showWeekNumber = true
    }

    static func current(in context: ModelContext) -> InternshipProfile {
        let descriptor = FetchDescriptor<InternshipProfile>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let profile = InternshipProfile()
        context.insert(profile)
        return profile
    }

    // Week 1 is the week containing startDate. Returns nil if startDate isn't set
    // or the internship hasn't started yet.
    func weekNumber(asOf date: Date = Date()) -> Int? {
        guard let startDate else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: date)
        guard today >= start else { return nil }
        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return (days / 7) + 1
    }
}
