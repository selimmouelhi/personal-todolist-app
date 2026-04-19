import SwiftUI

struct MonthCalendarView: View {
    let month: Date
    let selectedDate: Date
    let hasTasks: (Date) -> Bool
    let onChangeMonth: (Int) -> Void
    let onSelectDate: (Date) -> Void
    let onDropTask: (UUID, Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Button(action: { onChangeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Theme.textPrimary)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Theme.cardStrong)
                        )
                }
                .buttonStyle(.plain)

                Spacer()

                Text(month.formatted(.dateTime.month(.wide).year()))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                Button(action: { onChangeMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Theme.textPrimary)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Theme.cardStrong)
                        )
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                        .frame(maxWidth: .infinity)
                }

                ForEach(monthGrid, id: \.self) { value in
                    if let date = value {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 38)
                    }
                }
            }
        }
        .padding(22)
        .cardSurface()
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isDropTarget = monthContains(date)

        return Button {
            onSelectDate(date)
        } label: {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? Theme.backgroundBottom : Theme.textPrimary)

                Circle()
                    .fill(hasTasks(date) ? Theme.accent : .clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(backgroundColor(isSelected: isSelected, isToday: isToday))
            )
        }
        .buttonStyle(.plain)
        .dropDestination(for: String.self) { items, _ in
            guard isDropTarget,
                  let first = items.first,
                  let taskID = UUID(uuidString: first) else {
                return false
            }

            onDropTask(taskID, date)
            onSelectDate(date)
            return true
        }
    }

    private func backgroundColor(isSelected: Bool, isToday: Bool) -> Color {
        if isSelected {
            return Theme.accentWarm
        }
        if isToday {
            return Theme.accentCool.opacity(0.22)
        }
        return Theme.cardStrong
    }

    private var monthGrid: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastDay = calendar.date(byAdding: DateComponents(day: -1), to: monthInterval.end),
              let lastWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: lastDay) else {
            return []
        }

        var values: [Date?] = []
        var currentDate = firstWeekInterval.start

        while currentDate < lastWeekInterval.end {
            if monthInterval.contains(currentDate) {
                values.append(currentDate)
            } else {
                values.append(nil)
            }

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return values
    }

    private func monthContains(_ date: Date) -> Bool {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return false }
        return interval.contains(date)
    }
}
