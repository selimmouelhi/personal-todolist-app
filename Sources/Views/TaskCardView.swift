import SwiftUI

struct TaskCardView: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(task.isDone ? Theme.accent : Theme.outline, lineWidth: 2)
                        .background(
                            Circle()
                                .fill(task.isDone ? Theme.accent : .clear)
                        )
                        .frame(width: 24, height: 24)

                    if task.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.backgroundBottom)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(task.isDone ? Theme.textSecondary : Theme.textPrimary)
                    .strikethrough(task.isDone, color: Theme.textMuted)

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(Theme.textMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(task.isDone ? Theme.card : Theme.cardStrong)
        )
    }
}
