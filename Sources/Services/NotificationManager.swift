import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    let prompts = DailyPrompt.defaults
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func configure() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus

        if settings.authorizationStatus == .notDetermined {
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                authorizationStatus = granted ? .authorized : .denied
            } catch {
                authorizationStatus = .denied
            }
        }
    }

    func scheduleDailyPrompts() async {
        guard authorizationStatus == .authorized || authorizationStatus == .provisional else { return }

        let ids = prompts.map(\.id)
        center.removePendingNotificationRequests(withIdentifiers: ids)

        for prompt in prompts {
            let content = UNMutableNotificationContent()
            content.title = prompt.title
            content.body = prompt.body
            content.sound = .default

            var components = DateComponents()
            components.hour = prompt.hour
            components.minute = prompt.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: prompt.id, content: content, trigger: trigger)

            do {
                try await center.add(request)
            } catch {
                continue
            }
        }
    }
}
