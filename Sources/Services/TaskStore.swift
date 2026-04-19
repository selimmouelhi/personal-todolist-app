import Foundation

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published var draftTitle = ""
    @Published var draftNotes = ""
    @Published private(set) var editingTaskID: UUID?

    private let calendar = Calendar.current
    private let saveURL: URL

    init() {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folderURL = baseURL.appendingPathComponent("OnTrack", isDirectory: true)
        saveURL = folderURL.appendingPathComponent("tasks.json")

        load()
        refreshDayBoundary()
    }

    var todayTasks: [TaskItem] {
        tasks
            .filter { calendar.isDate($0.scheduledFor, inSameDayAs: .now) }
            .sorted(using: KeyPathComparator(\.createdAt))
    }

    var openTasks: [TaskItem] {
        todayTasks.filter { !$0.isDone }
    }

    var completedTasks: [TaskItem] {
        todayTasks.filter(\.isDone)
    }

    var completionRate: Double {
        guard !todayTasks.isEmpty else { return 0 }
        return Double(completedTasks.count) / Double(todayTasks.count)
    }

    var isEditingTask: Bool {
        editingTaskID != nil
    }

    func saveDraftTask() {
        let cleanedTitle = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedNotes = draftNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTitle.isEmpty else { return }

        if let editingTaskID,
           let index = tasks.firstIndex(where: { $0.id == editingTaskID }) {
            tasks[index].title = cleanedTitle
            tasks[index].notes = cleanedNotes
            tasks[index].updatedAt = .now
        } else {
            tasks.append(
                TaskItem(
                    title: cleanedTitle,
                    notes: cleanedNotes,
                    scheduledFor: startOfToday()
                )
            )
        }

        clearDraft()
        persist()
    }

    func toggleTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
        tasks[index].updatedAt = .now
        persist()
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        if editingTaskID == task.id {
            clearDraft()
        }
        persist()
    }

    func startEditing(_ task: TaskItem) {
        editingTaskID = task.id
        draftTitle = task.title
        draftNotes = task.notes
    }

    func cancelEditing() {
        clearDraft()
    }

    func refreshDayBoundary() {
        let today = startOfToday()
        var didChange = false

        for index in tasks.indices {
            let taskDay = calendar.startOfDay(for: tasks[index].scheduledFor)
            if taskDay < today && !tasks[index].isDone {
                tasks[index].scheduledFor = today
                tasks[index].updatedAt = .now
                didChange = true
            }
        }

        if didChange {
            persist()
        }
    }

    private func startOfToday() -> Date {
        calendar.startOfDay(for: .now)
    }

    private func load() {
        do {
            if !FileManager.default.fileExists(atPath: saveURL.path) {
                try FileManager.default.createDirectory(
                    at: saveURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                return
            }

            let data = try Data(contentsOf: saveURL)
            tasks = try JSONDecoder.decodeDates.decode([TaskItem].self, from: data)
        } catch {
            tasks = []
        }
    }

    private func persist() {
        do {
            try FileManager.default.createDirectory(
                at: saveURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder.pretty.encode(tasks)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            assertionFailure("Failed to save tasks: \(error.localizedDescription)")
        }
    }

    private func clearDraft() {
        editingTaskID = nil
        draftTitle = ""
        draftNotes = ""
    }
}

private extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var decodeDates: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
