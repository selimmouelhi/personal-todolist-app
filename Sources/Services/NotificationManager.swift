import AppKit
import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var prompts: [DailyPrompt] = []
    @Published private(set) var pendingReminderCount = 0
    @Published private(set) var lastNotificationMessage = "No notification has been shown yet."

    private let center: UNUserNotificationCenter
    private let saveURL: URL

    init(center: UNUserNotificationCenter = .current(), saveURL: URL? = nil) {
        self.center = center
        self.saveURL = saveURL ?? Self.defaultSaveURL
        super.init()
        self.center.delegate = self
        loadPrompts()
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

        await refreshPendingReminderCount()
    }

    func scheduleDailyPrompts() async {
        guard isAuthorized else { return }

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
                lastNotificationMessage = "Failed to schedule \(prompt.title)."
            }
        }

        await refreshPendingReminderCount()
    }

    func scheduleTestNotification() async {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "OnTrack test"
        content.body = "This is a reminder test from OnTrack."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: Self.testNotificationID, content: content, trigger: trigger)

        do {
            center.removePendingNotificationRequests(withIdentifiers: [Self.testNotificationID])
            try await center.add(request)
            lastNotificationMessage = "Scheduled a test notification for 5 seconds from now."
        } catch {
            lastNotificationMessage = "Failed to schedule the test notification."
        }

        await refreshPendingReminderCount()
    }

    func updatePrompt(_ prompt: DailyPrompt) {
        guard let index = prompts.firstIndex(where: { $0.id == prompt.id }) else { return }
        prompts[index] = prompt
        persistPrompts()
        Task {
            await scheduleDailyPrompts()
        }
    }

    func addPrompt() {
        let newPrompt = DailyPrompt(
            id: UUID().uuidString,
            hour: 18,
            minute: 0,
            title: "Custom reminder",
            body: "Pause and check what still matters today."
        )
        prompts.append(newPrompt)
        persistPrompts()
        Task {
            await scheduleDailyPrompts()
        }
    }

    func deletePrompts(at offsets: IndexSet) {
        let removedIDs = offsets.map { prompts[$0].id }
        prompts.remove(atOffsets: offsets)
        persistPrompts()
        center.removePendingNotificationRequests(withIdentifiers: removedIDs)

        Task {
            await scheduleDailyPrompts()
        }
    }

    func resetToDefaults() {
        prompts = DailyPrompt.defaults
        persistPrompts()
        Task {
            await scheduleDailyPrompts()
        }
    }

    func openNotificationSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorized || authorizationStatus == .provisional
    }

    private func loadPrompts() {
        do {
            if !FileManager.default.fileExists(atPath: saveURL.path) {
                prompts = DailyPrompt.defaults
                return
            }

            let data = try Data(contentsOf: saveURL)
            let decoder = JSONDecoder()
            prompts = try decoder.decode([DailyPrompt].self, from: data)
            if prompts.isEmpty {
                prompts = DailyPrompt.defaults
            }
        } catch {
            prompts = DailyPrompt.defaults
        }
    }

    private func persistPrompts() {
        do {
            try FileManager.default.createDirectory(
                at: saveURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(prompts)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            lastNotificationMessage = "Failed to save reminder changes."
        }
    }

    private func refreshPendingReminderCount() async {
        let requests = await center.pendingNotificationRequests()
        pendingReminderCount = requests.filter { $0.identifier != Self.testNotificationID }.count
    }

    private static let testNotificationID = "ontrack-test-notification"

    private static var defaultSaveURL: URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folderURL = baseURL.appendingPathComponent("OnTrack", isDirectory: true)
        return folderURL.appendingPathComponent("reminders.json")
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let title = notification.request.content.title
        await MainActor.run {
            lastNotificationMessage = "Displayed notification: \(title)"
        }
        return [.banner, .list, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let title = response.notification.request.content.title
        await MainActor.run {
            lastNotificationMessage = "Opened notification: \(title)"
        }
    }
}
