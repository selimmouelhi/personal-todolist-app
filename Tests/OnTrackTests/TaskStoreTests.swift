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

    private func temporarySaveURL() -> URL {
        let folderURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        return folderURL.appendingPathComponent("tasks.json")
    }
}
