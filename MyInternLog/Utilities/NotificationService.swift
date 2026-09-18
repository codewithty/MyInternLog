import Foundation
import UserNotifications

// Schedules local notifications for reminder slots and milestone reminders.
// Requests permission lazily, only when the user actually turns one on.
enum NotificationService {
    static let destinationKey = "destination"
    private static let reminderPrefix = "reminder-"
    private static let milestonePrefix = "milestone-"

    static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            return false
        }
    }

    // Replaces every reminder-slot notification (identified by prefix, so
    // milestone reminders scheduled separately are left untouched) with one
    // repeating request per enabled weekday per reminder.
    static func reschedule(_ reminders: [ReminderSetting]) {
        let center = UNUserNotificationCenter.current()
        removePending(withPrefix: reminderPrefix) {
            for reminder in reminders where reminder.isEnabled {
                let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)

                for weekday in reminder.enabledWeekdays {
                    var triggerComponents = DateComponents()
                    triggerComponents.hour = timeComponents.hour
                    triggerComponents.minute = timeComponents.minute
                    triggerComponents.weekday = weekday

                    let content = UNMutableNotificationContent()
                    content.title = reminder.label
                    content.body = reminder.message
                    content.sound = .default
                    content.userInfo = [destinationKey: reminder.destination.rawValue]

                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
                    let request = UNNotificationRequest(
                        identifier: "\(reminderPrefix)\(reminder.id.uuidString)-\(weekday)",
                        content: content,
                        trigger: trigger
                    )
                    center.add(request)
                }
            }
        }
    }

    // Milestone reminders fire once, at an exact date/time (on the day, the
    // day before, or the week before), rather than repeating weekly.
    static func scheduleMilestoneReminder(_ milestone: Milestone) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(milestonePrefix)\(milestone.id.uuidString)"])

        guard let option = milestone.reminderOption, option != .none, let fireDate = option.fireDate(for: milestone.date), fireDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = milestone.title
        content.body = "Milestone: " + milestone.type.label
        content.sound = .default

        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "\(milestonePrefix)\(milestone.id.uuidString)", content: content, trigger: trigger)
        center.add(request)
    }

    private static func removePending(withPrefix prefix: String, then action: @escaping () -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let idsToRemove = requests.map(\.identifier).filter { $0.hasPrefix(prefix) }
            center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
            DispatchQueue.main.async { action() }
        }
    }
}
