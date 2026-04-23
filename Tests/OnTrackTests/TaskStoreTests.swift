import XCTest
@testable import OnTrack

@MainActor
final class TaskStoreTests: XCTestCase {
    func testAddTaskFromDraftCreatesTaskAndClearsDraft() {
        let saveURL = temporarySaveURL()
        let store = TaskStore(saveURL: saveURL)
        let scheduledFor = Date(timeIntervalSince1970: 1_700_000_000)

        store.draftTitle = "Plan sprint"
        store.addTaskFromDraft(for: scheduledFor)

        XCTAssertEqual(store.tasks(on: scheduledFor).count, 1)
        XCTAssertEqual(store.tasks(on: scheduledFor).first?.title, "Plan sprint")
        XCTAssertEqual(store.tasks(on: scheduledFor).first?.notes, "")
        XCTAssertEqual(store.draftTitle, "")
    }

    func testUpdateTaskChangesTitleAndNotes() {
        let saveURL = temporarySaveURL()
        let store = TaskStore(saveURL: saveURL)
        let initialDate = Date(timeIntervalSince1970: 1_700_000_000)
        let updatedDate = Date(timeIntervalSince1970: 1_700_086_400)

        store.draftTitle = "Write draft"
        store.addTaskFromDraft(for: initialDate)

        guard let task = store.tasks(on: initialDate).first else {
            return XCTFail("Expected a task to be created")
        }

        store.updateTask(
            id: task.id,
            title: "Write final draft",
            notes: "Use the updated outline",
            scheduledFor: updatedDate
        )

        XCTAssertTrue(store.tasks(on: initialDate).isEmpty)
        XCTAssertEqual(store.tasks(on: updatedDate).first?.title, "Write final draft")
        XCTAssertEqual(store.tasks(on: updatedDate).first?.notes, "Use the updated outline")
    }

    func testNotificationManagerLoadsDefaults() {
        let manager = NotificationManager(saveURL: temporaryReminderURL())

        XCTAssertEqual(manager.prompts.count, 3)
        XCTAssertEqual(manager.prompts.map(\.title), [
            "Morning check-in",
            "Midday progress",
            "Wrap-up time"
        ])
    }

    func testNotificationManagerPersistsEditedPrompt() {
        let saveURL = temporaryReminderURL()
        let manager = NotificationManager(saveURL: saveURL)

        var updatedPrompt = manager.prompts[0]
        updatedPrompt.title = "Deep work checkpoint"
        updatedPrompt.body = "Make sure the most important work is moving."
        updatedPrompt.updateTime(from: date(hour: 10, minute: 45))

        manager.updatePrompt(updatedPrompt)

        let reloadedManager = NotificationManager(saveURL: saveURL)
        XCTAssertEqual(reloadedManager.prompts[0].title, "Deep work checkpoint")
        XCTAssertEqual(reloadedManager.prompts[0].body, "Make sure the most important work is moving.")
        XCTAssertEqual(reloadedManager.prompts[0].hour, 10)
        XCTAssertEqual(reloadedManager.prompts[0].minute, 45)
    }

    func testNotificationManagerResetToDefaultsReplacesSavedCustomPrompts() {
        let saveURL = temporaryReminderURL()
        let manager = NotificationManager(saveURL: saveURL)

        manager.addPrompt()
        XCTAssertEqual(manager.prompts.count, 4)

        manager.resetToDefaults()

        let reloadedManager = NotificationManager(saveURL: saveURL)
        XCTAssertEqual(reloadedManager.prompts, DailyPrompt.defaults)
    }

    func testRescheduleTaskToSelectedDayRemovesOverdueState() {
        let saveURL = temporarySaveURL()
        let store = TaskStore(saveURL: saveURL)
        let today = Calendar.current.startOfDay(for: .now)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        store.draftTitle = "Move me forward"
        store.addTaskFromDraft(for: yesterday)

        guard let task = store.tasks(on: yesterday).first else {
            return XCTFail("Expected an overdue task to be created")
        }

        XCTAssertEqual(store.overdueTasks(relativeTo: today).map(\.id), [task.id])

        store.rescheduleTask(id: task.id, to: today)

        XCTAssertTrue(store.overdueTasks(relativeTo: today).isEmpty)
        XCTAssertEqual(store.tasks(on: today).map(\.id), [task.id])
    }

    private func temporarySaveURL() -> URL {
        let folderURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        return folderURL.appendingPathComponent("tasks.json")
    }

    private func temporaryReminderURL() -> URL {
        let folderURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        return folderURL.appendingPathComponent("reminders.json")
    }

    private func date(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? .now
    }
}
