import Foundation

struct DailyPrompt: Identifiable, Hashable, Codable {
    var id: String
    var hour: Int
    var minute: Int
    var title: String
    var body: String

    var timeLabel: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let date = Calendar.current.date(from: components) ?? .now
        return formatter.string(from: date)
    }

    var timeDate: Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? .now
    }

    mutating func updateTime(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        hour = components.hour ?? hour
        minute = components.minute ?? minute
    }

    static let defaults: [DailyPrompt] = [
        DailyPrompt(
            id: "morning-check-in",
            hour: 9,
            minute: 0,
            title: "Morning check-in",
            body: "Did you add your tasks for today?"
        ),
        DailyPrompt(
            id: "midday-progress",
            hour: 12,
            minute: 30,
            title: "Midday progress",
            body: "What have you completed so far?"
        ),
        DailyPrompt(
            id: "wrap-up",
            hour: 16,
            minute: 0,
            title: "Wrap-up time",
            body: "Review today and plan tomorrow's priorities."
        )
    ]
}
