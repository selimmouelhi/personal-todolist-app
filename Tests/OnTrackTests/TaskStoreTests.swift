import XCTest
@testable import OnTrack

@MainActor
final class TaskStoreTests: XCTestCase {
    func testAddTaskFromDraftCreatesTaskAndClearsDraft() {
        let saveURL = temporarySaveURL()
        let store = TaskStore(saveURL: saveURL)

        store.draftTitle = "Plan sprint"
        store.addTaskFromDraft()

        XCTAssertEqual(store.todayTasks.count, 1)
        XCTAssertEqual(store.todayTasks.first?.title, "Plan sprint")
        XCTAssertEqual(store.todayTasks.first?.notes, "")
        XCTAssertEqual(store.draftTitle, "")
    }

    func testUpdateTaskChangesTitleAndNotes() {
        let saveURL = temporarySaveURL()
        let store = TaskStore(saveURL: saveURL)

        store.draftTitle = "Write draft"
        store.addTaskFromDraft()

        guard let task = store.todayTasks.first else {
            return XCTFail("Expected a task to be created")
        }

        store.updateTask(id: task.id, title: "Write final draft", notes: "Use the updated outline")

        XCTAssertEqual(store.todayTasks.first?.title, "Write final draft")
        XCTAssertEqual(store.todayTasks.first?.notes, "Use the updated outline")
    }

    private func temporarySaveURL() -> URL {
        let folderURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        return folderURL.appendingPathComponent("tasks.json")
    }
}
