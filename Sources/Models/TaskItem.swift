import Foundation

struct TaskItem: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var notes: String
    var isDone: Bool
    var createdAt: Date
    var updatedAt: Date
    var scheduledFor: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        isDone: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        scheduledFor: Date = .now
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.scheduledFor = scheduledFor
    }
}
