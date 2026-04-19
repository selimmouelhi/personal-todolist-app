import Foundation

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published var draftTitle = ""

    private let calendar = Calendar.current
    private let saveURL: URL

    init(saveURL: URL? = nil) {
        self.saveURL = saveURL ?? Self.defaultSaveURL

        load()
        refreshDayBoundary()
    }

    var allTasks: [TaskItem] {
        tasks.sorted {
            let leftDay = calendar.startOfDay(for: $0.scheduledFor)
            let rightDay = calendar.startOfDay(for: $1.scheduledFor)
            if leftDay == rightDay {
                return $0.createdAt < $1.createdAt
            }
            return leftDay < rightDay
        }
    }

    func tasks(on date: Date) -> [TaskItem] {
        allTasks.filter { calendar.isDate($0.scheduledFor, inSameDayAs: date) }
    }

    func openTasks(on date: Date) -> [TaskItem] {
        tasks(on: date).filter { !$0.isDone }
    }

    func completedTasks(on date: Date) -> [TaskItem] {
        tasks(on: date).filter(\.isDone)
    }

    func overdueTasks(relativeTo date: Date) -> [TaskItem] {
        let selectedDay = calendar.startOfDay(for: date)
        return allTasks.filter {
            !calendar.isDate($0.scheduledFor, inSameDayAs: date) &&
            calendar.startOfDay(for: $0.scheduledFor) < selectedDay &&
            !$0.isDone
        }
    }

    func completionRate(on date: Date) -> Double {
        let dayTasks = tasks(on: date)
        guard !dayTasks.isEmpty else { return 0 }
        return Double(completedTasks(on: date).count) / Double(dayTasks.count)
    }

    func taskCount(on date: Date) -> Int {
        tasks(on: date).count
    }

    func hasTasks(on date: Date) -> Bool {
        taskCount(on: date) > 0
    }

    func addTaskFromDraft(for date: Date) {
        let cleanedTitle = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTitle.isEmpty else { return }

        tasks.append(
            TaskItem(
                title: cleanedTitle,
                scheduledFor: calendar.startOfDay(for: date)
            )
        )

        clearDraft()
        persist()
    }

    func task(withID id: UUID) -> TaskItem? {
        tasks.first(where: { $0.id == id })
    }

    func updateTask(id: UUID, title: String, notes: String, scheduledFor: Date) {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTitle.isEmpty,
              let index = tasks.firstIndex(where: { $0.id == id }) else { return }

        tasks[index].title = cleanedTitle
        tasks[index].notes = cleanedNotes
        tasks[index].scheduledFor = calendar.startOfDay(for: scheduledFor)
        tasks[index].updatedAt = .now
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
        persist()
    }

    func refreshDayBoundary() {
        tasks = allTasks
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
        draftTitle = ""
    }

    private static var defaultSaveURL: URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folderURL = baseURL.appendingPathComponent("OnTrack", isDirectory: true)
        return folderURL.appendingPathComponent("tasks.json")
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
