import Foundation
import UserNotifications

// Schedules local notifications for reminder slots. Requests permission
// lazily, only when the user actually turns a reminder on.
enum NotificationService {

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

    // Cancels every reminder notification this app has scheduled, then
    // re-schedules one repeating request per enabled weekday per reminder.
    static func reschedule(_ reminders: [ReminderSetting]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

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

                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(reminder.id.uuidString)-\(weekday)",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }
        }
    }
}
