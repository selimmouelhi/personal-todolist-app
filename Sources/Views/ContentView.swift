import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: TaskStore
    @EnvironmentObject private var notifications: NotificationManager

    @State private var selectedTaskID: UUID?
    @State private var selectedDate = Calendar.current.startOfDay(for: .now)
    @State private var displayedMonth = Calendar.current.startOfDay(for: .now)

    private let calendar = Calendar.current

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                background

                HStack(alignment: .top, spacing: 20) {
                    sidebar
                        .frame(width: min(max(proxy.size.width * 0.31, 320), 390))

                    mainPanel
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 18)
            }
        }
        .sheet(
            isPresented: Binding(
                get: { selectedTaskID != nil },
                set: { isPresented in
                    if !isPresented {
                        selectedTaskID = nil
                    }
                }
            )
        ) {
            if let taskID = selectedTaskID,
               let task = store.task(withID: taskID) {
                TaskDetailView(task: task) { title, notes, scheduledFor in
                    store.updateTask(id: taskID, title: title, notes: notes, scheduledFor: scheduledFor)
                }
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

                    Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.horizontal, 4)

                statsCard
                dateNavigator
                monthCalendarCard
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
                        .trim(from: 0, to: store.completionRate(on: selectedDate))
                        .stroke(
                            AngularGradient(
                                colors: [Theme.accentCool, Theme.accent, Theme.accentWarm],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(store.completionRate(on: selectedDate) * 100))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                }
                .frame(width: 88, height: 88)

                VStack(alignment: .leading, spacing: 10) {
                    statLine(title: "Open", value: "\(store.openTasks(on: selectedDate).count)")
                    statLine(title: "Done", value: "\(store.completedTasks(on: selectedDate).count)")
                    statLine(title: "Total", value: "\(store.tasks(on: selectedDate).count)")
                    statLine(title: "Overdue", value: "\(store.overdueTasks(relativeTo: selectedDate).count)")
                }
            }
        }
        .padding(22)
        .cardSurface()
    }

    private var dateNavigator: some View {
        HStack(spacing: 10) {
            Button(action: selectPreviousDay) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Theme.textPrimary)
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Theme.cardStrong)
                    )
            }
            .buttonStyle(.plain)

            Button("Today") {
                selectedDate = calendar.startOfDay(for: .now)
                displayedMonth = calendar.startOfDay(for: .now)
            }
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(Theme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Theme.cardStrong)
            )
            .buttonStyle(.plain)

            Button(action: selectNextDay) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.textPrimary)
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Theme.cardStrong)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var monthCalendarCard: some View {
        MonthCalendarView(
            month: displayedMonth,
            selectedDate: selectedDate,
            hasTasks: { date in
                store.hasTasks(on: date)
            },
            onChangeMonth: { offset in
                shiftDisplayedMonth(by: offset)
            },
            onSelectDate: { date in
                selectedDate = calendar.startOfDay(for: date)
                displayedMonth = calendar.startOfDay(for: date)
            },
            onDropTask: { taskID, date in
                store.rescheduleTask(id: taskID, to: date)
            }
        )
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
            Text("Add a task")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            TextField("What matters on \(selectedDate.formatted(.dateTime.month(.abbreviated).day()))?", text: $store.draftTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.cardStrong))
                .onSubmit {
                    store.addTaskFromDraft(for: selectedDate)
                }

            Button {
                store.addTaskFromDraft(for: selectedDate)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add to \(selectedDateCallToAction)")
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

            Text("Press Enter to create the task on the selected day. Double-click a task card to open its full title, body, and date.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(22)
        .cardSurface()
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Daily rhythm")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                settingsButton
            }

            Text("Scheduled reminders: \(notifications.pendingReminderCount)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)

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

            Text("Edit reminder times and send a test notification from Settings.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(22)
        .cardSurface()
    }

    private var mainPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(mainTitle)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.horizontal, 2)

                Text(mainSubtitle)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 2)
            }

            if store.tasks(on: selectedDate).isEmpty && store.overdueTasks(relativeTo: selectedDate).isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if calendar.isDateInToday(selectedDate),
                           !store.overdueTasks(relativeTo: selectedDate).isEmpty {
                            sectionTitle("Overdue")

                            ForEach(store.overdueTasks(relativeTo: selectedDate)) { task in
                                taskCard(for: task)
                            }
                        }

                        if !store.openTasks(on: selectedDate).isEmpty {
                            sectionTitle(calendar.isDateInToday(selectedDate) ? "In motion" : "Open")

                            ForEach(store.openTasks(on: selectedDate)) { task in
                                taskCard(for: task)
                            }
                        }

                        if !store.completedTasks(on: selectedDate).isEmpty {
                            sectionTitle("Completed")

                            ForEach(store.completedTasks(on: selectedDate)) { task in
                                taskCard(for: task)
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
        .dropDestination(for: String.self) { items, _ in
            guard let first = items.first,
                  let taskID = UUID(uuidString: first) else {
                return false
            }

            store.rescheduleTask(id: taskID, to: selectedDate)
            return true
        }
    }

    private func taskCard(for task: TaskItem) -> some View {
        TaskCardView(task: task) {
            store.toggleTask(task)
        } onOpen: {
            selectedTaskID = task.id
        } onDelete: {
            store.deleteTask(task)
        }
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
            Text(calendar.isDateInToday(selectedDate) ? "A calm start." : "Nothing scheduled.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text("Use the calendar to move across past and future dates. Add tasks directly to the selected day, and open any task card to reschedule it when plans shift.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: 520, alignment: .leading)
        }
        .padding(.top, 48)
    }

    private var selectedDateCallToAction: String {
        calendar.isDateInToday(selectedDate) ? "today" : selectedDate.formatted(.dateTime.month(.abbreviated).day())
    }

    private var mainTitle: String {
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        }
        if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        }
        if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        }
        return selectedDate.formatted(.dateTime.weekday(.wide))
    }

    private var mainSubtitle: String {
        selectedDate.formatted(.dateTime.month(.wide).day().year())
    }

    private func selectPreviousDay() {
        guard let date = calendar.date(byAdding: .day, value: -1, to: selectedDate) else { return }
        selectedDate = calendar.startOfDay(for: date)
        displayedMonth = calendar.startOfDay(for: date)
    }

    private func selectNextDay() {
        guard let date = calendar.date(byAdding: .day, value: 1, to: selectedDate) else { return }
        selectedDate = calendar.startOfDay(for: date)
        displayedMonth = calendar.startOfDay(for: date)
    }

    private func shiftDisplayedMonth(by offset: Int) {
        guard let month = calendar.date(byAdding: .month, value: offset, to: displayedMonth) else { return }
        displayedMonth = calendar.startOfDay(for: month)
    }

    @ViewBuilder
    private var settingsButton: some View {
        if #available(macOS 14.0, *) {
            SettingsLink {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(Theme.textPrimary)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.cardStrong))
            }
            .buttonStyle(.plain)
        } else {
            Button(action: openLegacySettings) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(Theme.textPrimary)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.cardStrong))
            }
            .buttonStyle(.plain)
        }
    }

    private func openLegacySettings() {
        #if os(macOS)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        #endif
    }
}
