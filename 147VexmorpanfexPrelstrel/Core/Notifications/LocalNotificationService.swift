import Foundation
import UserNotifications

@MainActor
enum LocalNotificationService {
    private static let notifId = "lifestyle.gentle.daily"

    static func reschedule(using lifestyle: LifestyleData) {
        let c = UNUserNotificationCenter.current()
        c.removePendingNotificationRequests(withIdentifiers: [notifId])
        let e = lifestyle.extra
        guard e.reminderEnabled else { return }
        var dc = DateComponents()
        dc.hour = e.reminderHour
        dc.minute = e.reminderMinute
        let t = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "A small check-in"
        content.body = "Space for a quiet line or one gentle action, if this moment works for you."
        let req = UNNotificationRequest(identifier: notifId, content: content, trigger: t)
        c.add(req, withCompletionHandler: nil)
    }

    @discardableResult
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }
}
