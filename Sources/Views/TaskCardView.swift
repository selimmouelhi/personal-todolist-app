import SwiftUI

struct TaskCardView: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onEdit: () -> Void
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
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)

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

            HStack(spacing: 12) {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "square.and.pencil")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Theme.accentCool.opacity(0.22))
                        )
                }
                .buttonStyle(.borderless)

                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.red.opacity(0.24))
                        )
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(task.isDone ? Theme.card : Theme.cardStrong)
        )
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
