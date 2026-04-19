import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: TaskStore
    @EnvironmentObject private var notifications: NotificationManager

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                background

                HStack(alignment: .top, spacing: 20) {
                    sidebar
                        .frame(width: min(max(proxy.size.width * 0.29, 300), 360))

                    mainPanel
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 18)
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [Theme.backgroundTop, Theme.backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Theme.accentCool.opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: 100, y: -100)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(Theme.accentWarm.opacity(0.16))
                .frame(width: 340, height: 340)
                .blur(radius: 70)
                .offset(x: -120, y: 120)
        }
        .ignoresSafeArea()
    }

    private var sidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("OnTrack")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    Text(formattedDate)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.horizontal, 4)

                statsCard
                quickAddCard
                reminderCard
            }
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Daily pulse")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(Theme.outline, lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: store.completionRate)
                        .stroke(
                            AngularGradient(
                                colors: [Theme.accentCool, Theme.accent, Theme.accentWarm],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(store.completionRate * 100))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                }
                .frame(width: 88, height: 88)

                VStack(alignment: .leading, spacing: 10) {
                    statLine(title: "Open", value: "\(store.openTasks.count)")
                    statLine(title: "Done", value: "\(store.completedTasks.count)")
                    statLine(title: "Total", value: "\(store.todayTasks.count)")
                }
            }
        }
        .padding(22)
        .cardSurface()
    }

    private func statLine(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(Theme.textPrimary)
                .fontWeight(.semibold)
        }
        .font(.system(size: 14, weight: .medium, design: .rounded))
    }

    private var quickAddCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(store.isEditingTask ? "Edit task" : "Add a task")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                if store.isEditingTask {
                    Button("Cancel", action: store.cancelEditing)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .buttonStyle(.plain)
                }
            }

            TextField("What matters today?", text: $store.draftTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.cardStrong))

            TextField("Optional notes", text: $store.draftNotes, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.cardStrong))

            Button(action: store.saveDraftTask) {
                HStack {
                    Image(systemName: store.isEditingTask ? "checkmark" : "plus")
                    Text(store.isEditingTask ? "Save changes" : "Add to today")
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.backgroundBottom)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Theme.accent, Theme.accentWarm],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .cardSurface()
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Daily rhythm")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            ForEach(notifications.prompts) { prompt in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(prompt.title)
                            .foregroundStyle(Theme.textPrimary)
                        Text(prompt.body)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Spacer()

                    Text(prompt.timeLabel)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.accent)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.cardStrong))
            }
        }
        .padding(22)
        .cardSurface()
    }

    private var mainPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Today")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 2)

            if store.todayTasks.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if !store.openTasks.isEmpty {
                            sectionTitle("In motion")

                            ForEach(store.openTasks) { task in
                                TaskCardView(task: task) {
                                    store.toggleTask(task)
                                } onEdit: {
                                    store.startEditing(task)
                                } onDelete: {
                                    store.deleteTask(task)
                                }
                            }
                        }

                        if !store.completedTasks.isEmpty {
                            sectionTitle("Completed")

                            ForEach(store.completedTasks) { task in
                                TaskCardView(task: task) {
                                    store.toggleTask(task)
                                } onEdit: {
                                    store.startEditing(task)
                                } onDelete: {
                                    store.deleteTask(task)
                                }
                            }
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 20)
        .cardSurface()
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .tracking(1.6)
            .foregroundStyle(Theme.textMuted)
            .padding(.top, 4)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("A calm start.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text("Add the few tasks that matter today. Unfinished items will roll into tomorrow so the list stays honest without creating clutter.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: 520, alignment: .leading)
        }
        .padding(.top, 48)
    }

    private var formattedDate: String {
        Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}
