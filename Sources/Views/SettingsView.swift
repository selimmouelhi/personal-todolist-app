import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var notifications: NotificationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Reminders")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text(statusLine)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(notifications.prompts) { prompt in
                    HStack {
                        Text(prompt.title)
                        Spacer()
                        Text(prompt.timeLabel)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button("Refresh Notification Permission") {
                Task {
                    await notifications.configure()
                    await notifications.scheduleDailyPrompts()
                }
            }
        }
        .padding(24)
    }

    private var statusLine: String {
        switch notifications.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "Notifications are active on this Mac."
        case .denied:
            return "Notifications are turned off for OnTrack in System Settings."
        case .notDetermined:
            return "OnTrack has not requested notification access yet."
        @unknown default:
            return "Notification status is unavailable."
        }
    }
}
