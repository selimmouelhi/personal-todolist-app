import SwiftUI

@main
struct OnTrackApp: App {
    @StateObject private var store = TaskStore()
    @StateObject private var notifications = NotificationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(notifications)
                .frame(minWidth: 980, minHeight: 720)
                .task {
                    await notifications.configure()
                    await notifications.scheduleDailyPrompts()
                    store.refreshDayBoundary()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1180, height: 780)

        Settings {
            SettingsView()
                .environmentObject(notifications)
                .frame(width: 420, height: 280)
        }
    }
}
