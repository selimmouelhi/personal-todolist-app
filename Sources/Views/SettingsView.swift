import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var notifications: NotificationManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                statusCard
                remindersCard
                testingCard
            }
            .padding(24)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reminders")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("Edit the default check-ins, add your own, and fire a test notification while the app is open.")
                .foregroundStyle(.secondary)
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permission")
                .font(.system(size: 18, weight: .semibold, design: .rounded))

            Text(statusLine)
                .foregroundStyle(.secondary)

            Text("Scheduled daily reminders: \(notifications.pendingReminderCount)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Refresh Permission") {
                    Task {
                        await notifications.configure()
                        await notifications.scheduleDailyPrompts()
                    }
                }

                if notifications.authorizationStatus == .denied {
                    Button("Open System Settings") {
                        notifications.openNotificationSettings()
                    }
                }
            }
        }
    }

    private var remindersCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Daily reminders")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))

                Spacer()

                Button("Add reminder") {
                    notifications.addPrompt()
                }

                Button("Reset defaults") {
                    notifications.resetToDefaults()
                }
            }

            ForEach(notifications.prompts) { prompt in
                PromptEditorRow(prompt: prompt) { updatedPrompt in
                    notifications.updatePrompt(updatedPrompt)
                } onDelete: {
                    guard let index = notifications.prompts.firstIndex(where: { $0.id == prompt.id }) else { return }
                    notifications.deletePrompts(at: IndexSet(integer: index))
                }
            }
        }
    }

    private var testingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Testing")
                .font(.system(size: 18, weight: .semibold, design: .rounded))

            Text("Send a test notification. OnTrack now presents banners even while the app is frontmost, so this is the fastest way to verify the system is working.")
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Send test notification") {
                    Task {
                        await notifications.scheduleTestNotification()
                    }
                }
                .disabled(!notifications.isAuthorized)

                Text(notifications.lastNotificationMessage)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statusLine: String {
        switch notifications.authorizationStatus {
        case .authorized, .provisional:
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

private struct PromptEditorRow: View {
    let prompt: DailyPrompt
    let onChange: (DailyPrompt) -> Void
    let onDelete: () -> Void

    @State private var draft: DailyPrompt

    init(prompt: DailyPrompt, onChange: @escaping (DailyPrompt) -> Void, onDelete: @escaping () -> Void) {
        self.prompt = prompt
        self.onChange = onChange
        self.onDelete = onDelete
        _draft = State(initialValue: prompt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                TextField("Title", text: $draft.title)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(commitChanges)

                DatePicker(
                    "",
                    selection: Binding(
                        get: { draft.timeDate },
                        set: { newValue in
                            draft.updateTime(from: newValue)
                            commitChanges()
                        }
                    ),
                    displayedComponents: [.hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.compact)

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
            }

            TextField("Message", text: $draft.body, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
                .onSubmit(commitChanges)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.primary.opacity(0.04))
        )
        .onChange(of: draft.title) { _ in
            commitChanges()
        }
        .onChange(of: draft.body) { _ in
            commitChanges()
        }
        .onChange(of: prompt) { newValue in
            if draft != newValue {
                draft = newValue
            }
        }
    }

    private func commitChanges() {
        onChange(draft)
    }
}
