import Combine
import Foundation
import SwiftUI
import UIKit
import UserNotifications

enum NotificationDestination: Equatable {
    case quickCapture
    case reflection
}

// Holds the destination a tapped notification should open. AppDelegate
// writes to this; ContentView observes it and presents the right sheet.
final class NotificationRouter: ObservableObject {
    static let shared = NotificationRouter()
    @Published var pendingDestination: NotificationDestination?
}

// A pure SwiftUI app has no delegate by default, but UNUserNotificationCenter
// needs one to hear about notification taps while the app is running.
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let rawValue = response.notification.request.content.userInfo[NotificationService.destinationKey] as? String
        switch rawValue {
        case "reflection":
            NotificationRouter.shared.pendingDestination = .reflection
        default:
            NotificationRouter.shared.pendingDestination = .quickCapture
        }
        completionHandler()
    }

    // Also show the banner/sound if a reminder fires while the app is open.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
