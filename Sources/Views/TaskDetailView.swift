import SwiftUI

struct TaskDetailView: View {
    let task: TaskItem
    let onSave: (String, String, Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var notes: String
    @State private var scheduledFor: Date
    @State private var isShowingCalendar = false

    init(task: TaskItem, onSave: @escaping (String, String, Date) -> Void) {
        self.task = task
        self.onSave = onSave
        _title = State(initialValue: task.title)
        _notes = State(initialValue: task.notes)
        _scheduledFor = State(initialValue: task.scheduledFor)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.backgroundTop, Theme.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Task card")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.textPrimary)

                            Text("Open from any day to edit title, body, and date")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                        }

                        Spacer()

                        Button("Close", action: dismiss.callAsFunction)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Title")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(1.2)
                            .foregroundStyle(Theme.textMuted)

                        TextField("Task title", text: $title)
                            .textFieldStyle(.plain)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Theme.cardStrong)
                            )
                            .onSubmit(saveAndDismiss)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(1.2)
                            .foregroundStyle(Theme.textMuted)

                        Button {
                            isShowingCalendar.toggle()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(scheduledFor.formatted(.dateTime.weekday(.wide)))
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Theme.textPrimary)

                                    Text(scheduledFor.formatted(.dateTime.month(.wide).day().year()))
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(Theme.textSecondary)
                                }

                                Spacer()

                                Image(systemName: "calendar")
                                    .foregroundStyle(Theme.accent)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Theme.cardStrong)
                            )
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $isShowingCalendar) {
                            DatePicker(
                                "",
                                selection: $scheduledFor,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .padding(16)
                            .frame(width: 300)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Body")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(1.2)
                            .foregroundStyle(Theme.textMuted)

                        TextEditor(text: $notes)
                            .scrollContentBackground(.hidden)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .padding(12)
                            .frame(minHeight: 220)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Theme.cardStrong)
                            )
                    }

                    HStack {
                        Spacer()

                        Button(action: saveAndDismiss) {
                            Label("Save", systemImage: "checkmark")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.backgroundBottom)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [Theme.accent, Theme.accentWarm],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                )
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .padding(28)
            }
            .frame(minWidth: 540, minHeight: 480, alignment: .topLeading)
            .cardSurface()
            .padding(24)
        }
    }

    private func saveAndDismiss() {
        onSave(title, notes, scheduledFor)
        dismiss()
    }
}
