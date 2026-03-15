import Foundation
import UserNotifications

enum ReminderManager {
    private static let dailyReminderIdentifier = "com.slipless.daily-check-in"

    static func syncReminders(for habit: HabitProfile?, settings: SettingsManager) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])

        guard settings.dailyReminderEnabled else { return }
        guard await requestAuthorizationIfNeeded() else { return }

        if settings.dailyReminderEnabled {
            await scheduleDailyReminder(hour: settings.dailyReminderHour, minute: settings.dailyReminderMinute)
        }
    }

    private static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    private static func scheduleDailyReminder(hour: Int, minute: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-in"
        content.body = "Take a minute to log how you're doing today."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderIdentifier, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
}