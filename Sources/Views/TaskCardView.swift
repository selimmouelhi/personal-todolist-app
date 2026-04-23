import SwiftUI

private extension VerticalAlignment {
    private enum TaskTitleAlignment: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
            dimensions[.top]
        }
    }

    static let taskTitle = VerticalAlignment(TaskTitleAlignment.self)
}

struct TaskCardView: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onOpen: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(alignment: .taskTitle, spacing: 16) {
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
            .alignmentGuide(.taskTitle) { dimensions in
                dimensions[VerticalAlignment.center]
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(task.isDone ? Theme.textSecondary : Theme.textPrimary)
                    .strikethrough(task.isDone, color: Theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .alignmentGuide(.taskTitle) { dimensions in
                        dimensions[VerticalAlignment.center]
                    }

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 18)
        .padding(.leading, 18)
        .padding(.trailing, 56)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(task.isDone ? Theme.card : Theme.cardStrong)
        )
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.18))
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
            .padding(.trailing, 16)
            .opacity(isHovering ? 1 : 0)
            .scaleEffect(isHovering ? 1 : 0.92)
            .allowsHitTesting(isHovering)
        }
        .draggable(task.id.uuidString)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.16)) {
                isHovering = hovering
            }
        }
        .onTapGesture(count: 2, perform: onOpen)
    }
}
